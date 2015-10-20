module Spree
  module Wombat
    module Handler
      class SetInventoryHandler < Base

        def process
          stock_location_name = @payload[:inventory][:location]
          subscription_stock_location_name = "#{stock_location_name}_subscription"
          sku = @payload[:inventory][:product_id]
          quantity = @payload[:inventory][:quantity].to_i

          stock_location = Spree::StockLocation.find_by(name: stock_location_name) || Spree::StockLocation.find_by(admin_name: stock_location_name)
          return response("Stock location with name #{stock_location_name} was not found", 500) unless stock_location
          subscription_stock_location = Spree::StockLocation.find_by(name: subscription_stock_location_name) || Spree::StockLocation.find_by(admin_name: subscription_stock_location_name)

          variant = Spree::Variant.find_by(sku: sku)
          return response("Product with SKU #{sku} was not found", 500) unless variant

          stock_item = Spree::StockItem.find_by(stock_location: stock_location, variant: variant)
          return response("Stock location '#{stock_location_name}' does not have any stock_items for #{sku}", 500) unless stock_item
          subscription_stock_item = Spree::StockItem.find_by(stock_location: subscription_stock_location, variant: variant)

          count_on_hand = stock_item.count_on_hand
          subscription_count_on_hand = subscription_stock_item.try(:count_on_hand).to_i

          stock_item.set_count_on_hand(quantity - subscription_count_on_hand)

          msg = "Set inventory for #{sku} at #{stock_location_name} from #{count_on_hand} to "
          msg += "#{quantity} - #{subscription_count_on_hand} = " if subscription_stock_location && subscription_stock_item
          msg += "#{stock_item.reload.count_on_hand}"

          response(msg)
        end

      end
    end
  end
end
