require 'active_model/serializer'

module Spree
  module Wombat
    class VariantSerializer < ActiveModel::Serializer

      attributes :sku, :price, :cost_price, :list_price, :options, :weight, :height, :width, :depth,
                 :name, :short_name, :stock, :image_url, :servings_per_container
      has_many :images, serializer: Spree::Wombat::ImageSerializer

      def price
        object.price.to_f
      end

      def cost_price
        object.cost_price.to_f
      end

      def list_price
        object.list_price.to_f
      end

      def stock
        object.try(:total_on_hand).to_i
      end

      def image_url
        (object.images + object.product.images).first.try(:attachment,:small)
      end

      def servings_per_container
        object.try :servings_per_container
      end

      def options
        object.option_values.each_with_object({}) {|ov,h| h[ov.option_type.presentation]= ov.presentation}
      end

    end
  end
end
