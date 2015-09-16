require 'active_model/serializer'

module Spree
  module Wombat
    class CustomerSerializer < ActiveModel::Serializer

      attributes :id,:email, :firstname, :lastname, :document_number, :creation_date

      has_many :pets,  serializer: Spree::Wombat::PetSerializer


      def id
        object.email
      end

      def creation_date
      	object.created_at.strftime("%F %R")
      end

    end
  end
end
