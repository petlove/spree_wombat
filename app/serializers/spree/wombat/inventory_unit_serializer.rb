require 'active_model/serializer'

module Spree
  module Wombat
    class InventoryUnitSerializer < ActiveModel::Serializer
      attributes :product_id, :name, :quantity, :price, :weight, :height, :width, :depth,
                 :image_url, :product_url

      def quantity
        object.respond_to?(:quantity) ? object.quantity : 1
      end

      def price
        object.line_item.price.round(2).to_f
      end

      def product_id
        object.variant.sku
      end

      def name
        object.variant.name
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

      def image_url
        (object.variant.images + object.variant.product.images).first.try(:attachment,:small)
      end

      def product_url
        "http://www.petlove.com.br/%s/p" % object.variant.product.slug
      end
    end
  end
end
