require "spec_helper"

module Spree
  module Wombat
    describe CustomerSerializer do

      let(:user) { create(:user) }
      let(:serialized_customer) { CustomerSerializer.new(user, root: false).to_json }


      it "serializes the customer" do
        expect(JSON.parse(serialized_customer)["email"]).to eql user.email
              
      end
    end
  end
end
