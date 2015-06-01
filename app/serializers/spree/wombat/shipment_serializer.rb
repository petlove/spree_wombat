require 'active_model/serializer'

module Spree
  module Wombat
    class ShipmentSerializer < ActiveModel::Serializer
      attributes :id, :order_id, :email, :document_number, :cost, :status, :stock_location,
                :shipping_method, :tracking, :placed_on, :shipped_at, :totals,
                :updated_at, :channel, :items, :selected_shipping_rate,
                :order_status, :order_payment_status, :order_paid, :order_invoice

      has_one :bill_to, serializer: AddressSerializer, root: "billing_address"
      has_one :ship_to, serializer: AddressSerializer, root: "shipping_address"

      def id
        object.number
      end

      def order_id
        object.order.number
      end

      def email
        object.order.email
      end

      def document_number
        object.order.document_number
      end

      def channel
        object.order.channel || 'spree'
      end

      def cost
        object.cost.to_f
      end

      def status
        object.state
      end

      def order_status
        object.order.state
      end

      def order_payment_status
        object.order.payment_state
      end

      def order_paid
        object.order.paid?
      end

      def order_invoice
        object.order.invoice
      end

      def stock_location
        object.stock_location.slice(:name, :zipcode)
      end

      def shipping_method
        object.shipping_method.try(:name)
      end

      def selected_shipping_rate
        object.selected_shipping_rate
      end

      def placed_on
        if object.order.completed_at?
          object.order.completed_at.getutc.try(:iso8601)
        else
          ''
        end
      end

      def shipped_at
        object.shipped_at.try(:iso8601)
      end

      def totals
        {
          item: object.order.item_total.to_f,
          adjustment: adjustment_total,
          tax: tax_total,
          shipping: shipping_total,
          payment: object.order.payments.completed.sum(:amount).to_f,
          order: object.order.total.to_f
        }
      end

      def updated_at
        object.updated_at.iso8601
      end

      def items
        i = []
        object.inventory_units.each do |li|
          i << InventoryUnitSerializer.new(li, root: false)
        end
        i
      end

      private

        def adjustment_total
          object.order.adjustment_total.to_f
        end

        def shipping_total
          object.order.shipment_total.to_f
        end

        def tax_total
          object.order.tax_total.to_f
        end

    end
  end
end
