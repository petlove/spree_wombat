require 'active_model/serializer'

module Spree
  module Wombat
    class CustomerSerializer < ActiveModel::Serializer

      attributes :id,:email, :firstname, :lastname, :document_number, :creation_date, :city, :state,
                 :neighborhood, :zipcode, :birth_date, :phone, :newsletter_opt_in, :facebook_opt_in,
                 :sms_opt_in, :push_opt_in, :orders_count

      has_many :pets,  serializer: Spree::Wombat::PetSerializer


      def id
        object.email
      end

      def creation_date
        object.created_at.strftime("%F %R")
      end

      def ship_address
        object.try(:ship_addresses).try(:last)
      end

      def city
        ship_address.try(:city)
      end

      def state
        ship_address.try(:state).try(:name)
      end

      def neighborhood
        ship_address.try(:neighborhood)
      end

      def zipcode
        ship_address.try(:zipcode)
      end

      def birth_date
        object.birth_date ? object.birth_date.strftime("%F %R") : nil
      end 

      def orders_count
        object.orders.where.not(completed_at: nil).count
      end

    end
  end
end
