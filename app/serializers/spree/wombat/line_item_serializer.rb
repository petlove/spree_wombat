require 'active_model/serializer'

module Spree
  module Wombat
    class LineItemSerializer < ActiveModel::Serializer
      attributes :id, :product_id, :name, :quantity, :price, :weight, :height, :width, :depth,
      :promotional_item, :image_small_url, :product_url

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

      def image_small_url
        (object.variant.images + object.variant.product.images).first.try(:attachment,:small)
      end

      def product_url
        "http://www.petlove.com.br/%s/p" % object.variant.product.slug
      end

    end
  end
end
