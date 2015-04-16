require 'active_model/serializer'

module Spree
  module Wombat
    class AddressSerializer < ActiveModel::Serializer
      attributes :firstname, :lastname, :address1, :address2, :zipcode, :city,
                 :state, :country, :phone, :house_number, :neighborhood

      def country
        object.country.try(:iso)
      end

      def state
        if object.state
          object.state.abbr
        else
          object.state_name
        end
      end
    end
  end
end
