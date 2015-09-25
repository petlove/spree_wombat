require 'active_model/serializer'

module Spree
  module Wombat
    class ProductSerializer < ActiveModel::Serializer

      attributes :id, :name, :sku, :description, :price, :list_price, :cost_price,
                 :available_on, :permalink, :meta_description, :meta_keywords,
                 :shipping_category, :taxons, :options, :weight, :height, :width,
                 :depth, :store_variants, :url, :brand, :department, :category, :subcategory,
                 :average_serving_size, :properties

      has_many :images, serializer: Spree::Wombat::ImageSerializer

      def id
        object.sku
      end

      def list_price
        object.list_price.to_f
      end

      def price
        object.price.to_f
      end

      def cost_price
        object.cost_price.to_f
      end

      def available_on
        object.available_on.try(:iso8601)
      end

      def permalink
        object.slug
      end

      def url
        "http://www.petlove.com.br/%s/p" % object.slug
      end

      def brand
        object.send(:brand).try(:name) if object.respond_to?(:brand)
      end

      def department
        object.send(:department).try(:name) if object.respond_to?(:department)
      end

      def category
        object.send(:category).try(:name) if object.respond_to?(:category)
      end

      def subcategory
        object.send(:sub_category).try(:name) if object.respond_to?(:sub_category)
      end

      def average_serving_size
        object.try :average_serving_size
      end

      def shipping_category
        object.shipping_category.name
      end

      def taxons
        object.taxons.collect {|t| t.self_and_ancestors.collect(&:name)}
      end

      def options
        object.option_types.pluck(:name)
      end

      def properties
        object.try(:properties)
      end

      def store_variants
        if object.variants.empty?
          [Spree::Wombat::VariantSerializer.new(object.master, root:false)]
        else
          ActiveModel::ArraySerializer.new(
            object.variants,
            each_serializer: Spree::Wombat::VariantSerializer,
            root: false
          )
        end
      end
    end
  end
end
