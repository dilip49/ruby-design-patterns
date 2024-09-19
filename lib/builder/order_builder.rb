# frozen_string_literal: true

require_relative "order"
require "debug"

class OrderBuilder
  def initialize
    @order = Order.new
  end

  def add_product(product_name)
    @order.products << product_name
    self
  end

  def add_shipping_method(method)
    @order.shipping_method = method
    self
  end

  def add_payment_method(method)
    @order.payment_method = method
    self
  end

  def apply_discount(discount)
    @order.discount = discount
    self
  end

  def add_gift_wrap
    @order.gift_wrap = true
    self
  end

  def build
    @order
  end
end

builder = OrderBuilder.new

order = builder
        .add_product("Laptop")
        .add_product("Headphones")
        .add_shipping_method("Express Shipping")
        .add_payment_method("Credit Card")
        .apply_discount("10% OFF")
        .add_gift_wrap
        .build

puts order.details
