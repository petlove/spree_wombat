module Spree
  module Wombat
    module Handler
      class SetInventoryHandler < Base

        def process
          stock_location_name = @payload[:inventory][:location]
          sku = @payload[:inventory][:product_id]

          stock_location = Spree::StockLocation.find_by(name: stock_location_name) || Spree::StockLocation.find_by(admin_name: stock_location_name)
          return response("Stock location with name #{stock_location_name} was not found", 500) unless stock_location

          variant = Spree::Variant.find_by(sku: sku) || Spree::Variant.unscoped.find_by(sku: sku)
          return response("Product with SKU #{sku} was not found", 500) unless variant

          stock_item = Spree::StockItem.find_by(stock_location: stock_location, variant: variant) || Spree::StockItem.unscoped.find_by(stock_location: stock_location, variant: variant) unless stock_item
          return response("Stock location '#{stock_location_name}' does not have any stock_items for #{sku}", 500) unless stock_item

          count_on_hand = stock_item.count_on_hand
          stock_item.set_count_on_hand(@payload[:inventory][:quantity])

          response("Set inventory for #{sku} at #{stock_location_name} from #{count_on_hand} to #{stock_item.reload.count_on_hand}")
        end

      end
    end
  end
end