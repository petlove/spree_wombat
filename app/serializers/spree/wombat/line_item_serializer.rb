require 'active_model/serializer'

module Spree
  module Wombat
    class LineItemSerializer < ActiveModel::Serializer
      attributes :product_id, :name, :quantity, :price, :weight, :height, :width, :depth,
      :promotional_item, :image_url, :product_url

      def product_id
        object.variant.sku
      end

      def name
        object.name
      end

      def quantity
        object.respond_to?(:quantity) ? object.quantity.to_i : 1
      end

      def price
        object.price.to_f
      end

      def weight
        object.variant.weight.round(4).to_f
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

      def promotional_item
        object.promotional_item
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
