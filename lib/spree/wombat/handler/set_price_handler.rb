module Spree
  module Wombat
    module Handler
      class SetPriceHandler < Base
        def process
          sku = @payload[:price].delete(:product_id)
          variant = Spree::Variant.unscoped.find_by(vtex_sku_id: sku)
          return response("Product with VTEX SKU ID #{sku} was not found", 500) unless variant

          updatable_columns = @payload[:price].slice *Spree::Variant.attribute_names.select{|n| n =~ /price/i }.concat(["price"])
          return response("Missing price information", 500) unless updatable_columns[:price]

          current_price = variant.price
          current_currency = variant.currency

          Spree::Variant.transaction do
            variant.update_attributes!(updatable_columns)
          end
          variant.reload

          return response("Set price for #{sku} from #{current_price} #{current_currency} to #{variant.price} #{variant.currency}")
        end
      end
    end
  end
end