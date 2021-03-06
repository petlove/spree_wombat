require 'spec_helper'

module Spree
  module Wombat
    describe Handler::UpdateProductHandler do
      # before do
      #   img_fixture = File.open(File.expand_path('../../../../../fixtures/thinking-cat.jpg', __FILE__), 'rb')
      #   Paperclip::UriAdapter.any_instance.stub(:download_content).and_return(img_fixture)
      # end

      it "respond properly if product not found" do
        handler = described_class.new Hub::Samples::Product.request.to_json
        response = handler.process
        expect(response.summary).to match "Cannot find product with SKU"
      end

      it "doesnt create duplicated variant" do
        message = {
          product: {
            name: 'rails',
            sku: 'rails',
            shipping_category: 'default',
            price: 30,
            variants: [
              {
                sku: 'not rails',
                deleted_at: Time.now,
                options: []
              }
            ]
          }
        }

        expect {
          handler = Handler::AddProductHandler.new message.to_json
          handler.process
        }.to change { Variant.unscoped.count }.by(2)

        expect {
          handler = described_class.new message.to_json
          response = handler.process
        }.not_to change { Variant.unscoped.count }
      end

      context "#process" do
        let!(:message) do
          hsh = ::Hub::Samples::Product.request
          hsh["product"]["permalink"] = "other-permalink-then-name"
          hsh["product"]["images"] = [{"url" => 'http://dummyimage.com/1000x1000', "position" => 0, "title" => 'test 1000x1000' }]
          hsh["product"]["variants"][0]["images"] = [{"url" => 'http://dummyimage.com/800x800', "position" => 0, "title" => 'test 800x800' }]
          hsh
        end

        let!(:variant) do
          p = create(:product)
          p.master.update_attributes(sku: message["product"]["sku"])
          p.master
        end

        let(:handler) { Handler::UpdateProductHandler.new(message.to_json) }

        it "updates a product in the storefront" do
          expect {
            handler.process
          }.not_to change{ Spree::Product.count }
        end

        it "adds new variant in the storefront" do
          expect {
            handler.process
          }.to change { Spree::Variant.count }.by 1
        end

        context "and with a permalink" do
          before do
            handler.process
          end

          it "updates store the permalink as the slug" do
            expect(Spree::Product.where(slug: message["product"]["permalink"]).count).to eql 1
          end
        end

        context "and regarding taxons" do
          let(:message_without_taxons) do
            message["product"].delete("taxons")
            message["product"]["images"] = [{"url" => 'http://dummyimage.com/1000x1000', "position" => 0, "title" => 'test 1000x1000' }]
            message["product"]["variants"][0]["images"] = [{"url" => 'http://dummyimage.com/800x800', "position" => 0, "title" => 'test 800x800' }]
            message
          end

          let(:message_with_empty_taxons) do
            message["product"]["taxons"] = []
            message["product"]["images"] = [{"url" => 'http://dummyimage.com/1000x1000', "position" => 0, "title" => 'test 1000x1000' }]
            message["product"]["variants"][0]["images"] = [{"url" => 'http://dummyimage.com/800x800', "position" => 0, "title" => 'test 800x800' }]
            message
          end

          let(:message_with_different_taxons) do
            message["product"]["taxons"] = [["Categories", "Scuba Gear"], ["Brands", "Scuba"]]
            message["product"]["images"] = [{"url" => 'http://dummyimage.com/1000x1000', "position" => 0, "title" => 'test 1000x1000' }]
            message["product"]["variants"][0]["images"] = [{"url" => 'http://dummyimage.com/800x800', "position" => 0, "title" => 'test 800x800' }]
            message
          end

          let(:handler_without_taxons) { Handler::UpdateProductHandler.new(message_without_taxons.to_json) }
          let(:handler_with_empty_taxons) { Handler::UpdateProductHandler.new(message_with_empty_taxons.to_json) }
          let(:handler_with_different_taxons) { Handler::UpdateProductHandler.new(message_with_different_taxons.to_json) }

          let(:product) { Spree::Variant.find_by_sku(message["product"]["sku"]).product }

          before do
            handler.process
          end

          it "updates a product with taxons" do
            expect(product.taxons.size).to eq 3
          end

          it "updates a product without taxons" do
            expect(product.taxons.size).to eq 3

            handler_without_taxons.process
            expect(product.taxons.size).to eq 3
          end

          it "updates a product with empty taxons" do
            expect(product.taxons.size).to eq 3

            handler_with_empty_taxons.process
            expect(product.taxons.size).to eq 0
          end

          it "updates a product with different taxons" do
            expect(product.taxons.size).to eq 3

            handler_with_different_taxons.process
            expect(product.taxons.size).to eq 2
          end
        end


        context "response" do
          let(:responder) { handler.process }

          it "is a Hub::Responder" do
            expect(responder.class.name).to eql "Spree::Wombat::Responder"
          end

          it "returns the original request_id" do
            expect(responder.request_id).to eql message["request_id"]
          end

          it "returns http 200" do
            expect(responder.code).to eql 200
          end

          it "returns a summary with the updated product and variant id's" do
            expect(responder.summary).to match "updated"
          end
        end
      end
    end
  end
end
