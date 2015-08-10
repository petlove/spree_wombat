module Spree
  module Wombat
    module Handler
      class CancelOrderHandler < OrderHandlerBase

        def process
          order_number = @payload[:order][:id]
          return response("Invalid status: #{@payload[:order][:status]} for order with number #{order_number}", 500) unless @payload[:order][:status] == 'erp_canceled'

          order = Spree::Order.lock(true).find_by(number: order_number)
          return response("Order with number #{order_number} was not found", 500) unless order
          return response("Order already canceled", 200) if order.canceled?

          if order.cancel
            response "Canceled Order with number #{order_number}"
          else
            response("Order with number #{order_number} could not be canceled (state: #{order.state}). #{order.errors.full_messages.join("; ")}", 500)
          end
        end
      end
    end
  end
end
 