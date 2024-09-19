# frozen_string_literal: true

class Order
  attr_accessor :products, :shipping_method, :payment_method, :discount, :gift_wrap

  def initialize
    @products = []
  end

  def details
    "Order: Products: #{@products.join(', ')}, Shipping: #{@shipping_method}, Payment: #{@payment_method}, " \
      "Discount: #{@discount}, Gift Wrap: #{@gift_wrap ? 'Yes' : 'No'}"
  end
end
