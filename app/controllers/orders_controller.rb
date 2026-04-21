class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer
  before_action :set_order, only: [:show, :pay]

  def index
    @orders = if @customer
      @customer.orders
               .includes(order_items: :product)
               .order(created_at: :desc)
    else
      Order.none
    end
  end

  def show
  end

  def pay
    configure_stripe!

    unless stripe_configured?
      redirect_to order_path(@order), alert: "Stripe is not configured yet. Please set STRIPE_SECRET_KEY and try again."
      return
    end

    if @order.payment_status == "paid"
      redirect_to order_path(@order), notice: "This order has already been paid."
      return
    end

    stripe_session = Stripe::Checkout::Session.create(
      mode: "payment",
      client_reference_id: @order.id.to_s,
      customer_email: @order.customer.email,
      success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: order_url(@order),
      line_items: @order.order_items.map do |item|
        {
          quantity: item.quantity,
          price_data: {
            currency: "cad",
            unit_amount: (item.unit_price * 100).to_i,
            product_data: {
              name: item.product.name,
              description: item.product.description.to_s.truncate(100)
            }
          }
        }
      end,
      payment_intent_data: {
        metadata: {
          order_id: @order.id.to_s
        }
      },
      metadata: {
        order_id: @order.id.to_s
      }
    )

    @order.update!(stripe_checkout_session_id: stripe_session.id)
    redirect_to stripe_session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to order_path(@order), alert: "Stripe could not start checkout: #{e.message}"
  end

  private

  def set_customer
    @customer = Customer.find_by(email: current_user.email)
  end

  def set_order
    @order = @customer.orders
                      .includes(:customer, order_items: :product)
                      .find(params[:id])
  end

  def stripe_configured?
    Stripe.api_key.present?
  end

  def configure_stripe!
    Stripe.api_key = resolved_stripe_key
  end

  def resolved_stripe_key
    ENV["STRIPE_SECRET_KEY"].presence || stripe_key_from_env_file
  end

  def stripe_key_from_env_file
    env_file = Rails.root.join(".env")
    return if !File.exist?(env_file)

    env_line = File.readlines(env_file).find { |line| line.strip.start_with?("STRIPE_SECRET_KEY=") }
    return if env_line.blank?

    env_line.split("=", 2).last.to_s.strip.delete_prefix('"').delete_suffix('"').delete_prefix("'").delete_suffix("'")
  end
end
