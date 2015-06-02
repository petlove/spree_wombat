require 'active_model/serializer'

module Spree
  module Wombat
    class InventoryUnitSerializer < ActiveModel::Serializer
      attributes :product_id, :name, :quantity, :price, :weight, :height, :width, :depth,
                 :image_url, :product_url

      def quantity
        object.respond_to?(:quantity) ? object.quantity.to_i : 1
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
        object.variant.weight.round(4).to_f
      end

      def height
        object.variant.height.round(4).to_f
      end

      def width
        object.variant.width.round(4).to_f
      end

      def depth
        object.variant.depth.round(4).to_f
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
