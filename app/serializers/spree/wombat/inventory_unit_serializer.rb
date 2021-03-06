require 'active_model/serializer'

module Spree
  module Wombat
    class InventoryUnitSerializer < ActiveModel::Serializer
      attributes :product_id, :name, :quantity, :price, :weight, :height, :width, :depth,
                 :image_url, :product_url

      def product_id
        object.variant.sku
      end

      def name
        object.variant.name
      end

      def quantity
        object.respond_to?(:quantity) ? object.quantity.to_i : 1
      end

      def price
        object.line_item.try(:price).to_f.round(2)
      end

      def weight
        object.variant.weight.to_f.round(4)
      end

      def height
        object.variant.height.to_f
      end

      def width
        object.variant.width.to_f
      end

      def depth
        object.variant.depth.to_f
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
