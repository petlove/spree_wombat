module Spree
  module Wombat
    module Handler
      class SetPriceHandler < Base
        def process
          sku = @payload[:price][:sku]
          variant = Spree::Variant.find_by(sku: sku)
          return response("Product with sku #{sku} was not found", 500) unless variant

          updatable_columns = @payload[:price].slice(:price)
          return response("Missing price information", 500) unless updatable_columns[:price]

          current_price = variant.price
          current_currency = variant.currency

          Spree::Variant.transaction do
            variant.update_attributes!(updatable_columns)
          end
          variant.reload

          return response("Set price for #{sku_id} from #{current_price} #{current_currency} to #{variant.price} #{variant.currency}")
        end
      end
    end
  end
end
