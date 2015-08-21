require 'active_model/serializer'

module Spree
  module Wombat
    class CustomerSerializer < ActiveModel::Serializer

      attributes :id,:email, :firstname, :lastname, :document_number

      has_many :pets,  serializer: Spree::Wombat::PetSerializer


      def id
        object.email
      end

    end
  end
end
