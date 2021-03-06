require "spec_helper"

describe Spree::Wombat::Client do

  let!(:order) { create(:shipped_order) }
  let(:incomplete_order) { create(:order, completed_at: nil) }
  let(:order_payment) { create(:payment, order: incomplete_order, document_number: '11111111111') }

  describe ".push_item" do
    it "pushes a serialized object" do
      serialized_order = Spree::Wombat::OrderSerializer.new(order, root: false)
      expect(described_class).to receive(:push).with({
        "orders" => [
          serialized_order
        ]
      }.to_json)
      described_class.push_item(order.class.to_s, order.id)
    end

    it "raises an RecordNotFound exception" do
      expect { described_class.push_item(order.class.to_s, order.id + 1) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns true" do
      expect(HTTParty).to receive(:post).and_return(double(code: 202, body: "Success"))
      expect(described_class.push_item(order.class.to_s, order.id)).to be nil
    end
  end

  describe ".push_batches" do
    it "pushes all orders updated recently" do
      second_order = create(:shipped_order)

      expect(described_class).to receive(:push).with({
        "orders" => [
          Spree::Wombat::OrderSerializer.new(order, root: false),
          Spree::Wombat::OrderSerializer.new(second_order, root: false)
        ]
      }.to_json)
      described_class.push_batches(order.class.to_s)
    end

    it "respects the timestamp offset" do
      old_order = create(:shipped_order)
      old_order.update_column(:updated_at, Time.now - 4.minutes)

      older_order = create(:shipped_order)
      older_order.update_column(:updated_at, Time.now - 10.minutes)

      expect(described_class).to receive(:push).with({
        "orders" => [
          Spree::Wombat::OrderSerializer.new(order, root: false),
          Spree::Wombat::OrderSerializer.new(old_order, root: false)
        ]
      }.to_json)
      described_class.push_batches(order.class.to_s, 5.minutes)
    end

    it "uses the payload root" do
      stubbed_config = {
        :last_pushed_timestamps => {
          "Spree::Order" => Time.now
        },
        :payload_builder => {
          "Spree::Order" => {
            :serializer => "Spree::Wombat::OrderSerializer",
            :root => "godzilla"
          }
        }
      }
      stub_config("Spree::Order", stubbed_config)
      expect(described_class).to receive(:push).with({
        "godzilla" => [
          Spree::Wombat::OrderSerializer.new(order, root: false)
        ]
      }.to_json)
      described_class.push_batches(order.class.to_s)
    end

    it "uses the filter" do
      stubbed_config = {
        :payload_builder => {
          "Spree::Order" => {
            :serializer => "Spree::Wombat::OrderSerializer",
            :root => "orders",
            :filter => "incomplete"
          }
        }
      }
      order_payment
      stub_config("Spree::Order", stubbed_config)
      expect(described_class).to receive(:push).with({
        "orders" => [
          Spree::Wombat::OrderSerializer.new(incomplete_order, root: false)
        ]
      }.to_json)
      described_class.push_batches(order.class.to_s)
    end
  end

  describe ".validate" do
    it "returns true" do
      response = double(code: 202, body: "Success")
      expect(described_class.validate(response)).to be nil
    end

    it "raises an exception" do
      response = double(code: 500, body: "Error")
      expect { described_class.validate(response) }.to raise_error(PushApiError)
    end
  end

  describe ".push" do
    it "uses the configured push_url" do
      described_class.stub(:validate)
      expect(HTTParty).to receive(:post).with("http://godzilla.org", anything)
      stub_config("Spree::Order", { push_url: "http://godzilla.org" } )
      described_class.push({}.to_json)
    end
  end
end

def stub_config(class_name, options={})
  options[:last_pushed_timestamps]  ||= {class_name => Spree::Wombat::Config[:last_pushed_timestamps][class_name.to_s]}
  options[:payload_builder]         ||= {class_name => Spree::Wombat::Config[:payload_builder][class_name.to_s]}
  options[:batch_size]              ||= Spree::Wombat::Config[:batch_size]
  options[:push_url]                ||= Spree::Wombat::Config[:push_url]
  options[:connection_id]           ||= Spree::Wombat::Config[:connection_id]
  options[:connection_token]        ||= Spree::Wombat::Config[:connection_token]

  options.each_pair do |key, value|
    allow(Spree::Wombat::Config).to receive(:[]).with(key).and_return(value)
  end
end
