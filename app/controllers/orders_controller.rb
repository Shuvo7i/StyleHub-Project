class OrdersController < ApplicationController
  def show
    @order = Order.includes(:customer, order_items: :product).find(params[:id])
  end
end