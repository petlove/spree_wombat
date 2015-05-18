require 'active_model/serializer'

module Spree
  module Wombat
    class LineItemSerializer < ActiveModel::Serializer
      attributes :id, :product_id, :name, :quantity, :price, :weight, :height, :width, :depth, :promotional_item

      def product_id
        object.variant.sku
      end

      def price
        object.price.to_f
      end

      def promotional_item
        object.promotional_item
      end

      def weight
        object.variant.weight
      end

      def height
        object.variant.height
      end

      def width
        object.variant.width
      end

      def depth
        object.variant.depth
      end

    end
  end
end
