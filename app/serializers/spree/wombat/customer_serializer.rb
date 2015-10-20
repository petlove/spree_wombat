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

      def firstname
        object.try :firstname
      end

      def lastname
        object.try :lastname
      end

      def document_number
        object.try :document_number
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
        object.try(:birth_date) ? object.birth_date.strftime("%F %R") : nil
      end

      def phone
        object.try :phone
      end

      def newsletter_opt_in
        object.try :newsletter_opt_in
      end

      def facebook_opt_in
        object.try :facebook_opt_in
      end

      def sms_opt_in
        object.try :sms_opt_in
      end

      def push_opt_in
        object.try :push_opt_in
      end

      def orders_count
        object.orders.where.not(completed_at: nil).count
      end

    end
  end
end
