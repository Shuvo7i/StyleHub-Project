class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @customer = Customer.find_by(email: current_user.email)

    @orders = if @customer
      @customer.orders
               .includes(order_items: :product)
               .order(created_at: :desc)
    else
      Order.none
    end
  end

  def show
    @customer = Customer.find_by(email: current_user.email)

    @order = @customer.orders
                      .includes(:customer, order_items: :product)
                      .find(params[:id])
  end
end