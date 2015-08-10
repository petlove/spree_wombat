require 'spec_helper'

module Spree
  module Wombat
    describe Handler::CancelOrderHandler do

      context "#process" do

        let!(:message) { ::Hub::Samples::Order.request }
        let(:handler) { Handler::CancelOrderHandler.new(message.to_json) }

        context "with invalid status" do
          it "returns a Wombat::Responder with 500 status" do
            responder = handler.process
            expect(responder.summary).to match /Invalid status/
            expect(responder.code).to eql 500
          end
        end

        context "with a valid status" do
          let!(:message) do
            msg = ::Hub::Samples::Order.request
            msg["order"].merge!("status" => "erp_canceled")
            msg
          end

          context "with no order present" do
            it "returns a Wombat::Responder with 500 status" do
              responder = handler.process
              expect(responder.summary).to match /Order with number R.{9} was not found/
              expect(responder.code).to eql 500
            end
          end

          context "for existing incomplete order" do
            let!(:order) { create(:order_with_line_items, number: message["order"]["id"]) }

            it "returns a Wombat::Responder with 500 status" do
              responder = handler.process
              expect(responder.summary).to  match /Order with number R.{9} could not be canceled/
              expect(responder.code).to eql 500
            end
          end

          context "for existing completed order" do
            let!(:order) { create(:completed_order_with_totals, number: message["order"]["id"]) }

            it "will cancel the order" do
              responder = handler.process
              expect(responder.summary).to  match /Canceled Order with number R.{9}/
              expect(responder.code).to eql 200

              expect(order.reload.state).to eql 'canceled'
            end
          end
        end
      end

    end
  end
end
