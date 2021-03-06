require 'active_model/serializer'

module Spree
  module Wombat
    class PaymentSerializer < ActiveModel::Serializer
      attributes :id, :number, :status, :amount, :payment_method, :installments, :url_referral, :billet_code

      has_one :source, serializer: Spree::Wombat::SourceSerializer

      def number
        object.identifier
      end

      def payment_method
        object.payment_method.try(:name)
      end

      def status
        object.state
      end

      def amount
        object.amount.to_f
      end

      def url_referral
        object.url_referral
      end

      def billet_code
        object.billet_code
      end
    end
  end
end
