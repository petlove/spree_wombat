module Spree
  module Wombat
    module Handler
      class UpdateOrderHandler < OrderHandlerBase

        def process
          order_payload = @payload[:order]
          order_number = order_payload[:id]
          order = Spree::Order.lock(true).find_by(number: order_number)
          return response("Order with number #{order_number} was not found", 500) unless order
          params = {
            state: order_payload[:status],
            email: order_payload[:email],
            invoice: order_payload[:invoice],
            integration_protocol: order_payload[:integration_protocol],

            # erp state related date fields
            erp_integrated_at: order_payload[:erp_integrated_at],
            erp_invoiced_at: order_payload[:erp_invoiced_at],
            erp_shipped_at: order_payload[:erp_shipped_at],
            erp_delivered_at: order_payload[:erp_delivered_at],
          }.compact
          order.update_attributes!(params)
          response "Updated Order with number #{order_number}"
        end
      end
    end
  end
end
