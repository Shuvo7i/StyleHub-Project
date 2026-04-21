class CheckoutController < ApplicationController
  def new
    session[:cart] ||= {}

    if session[:cart].blank?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    if user_signed_in?
      @customer = Customer.new(
        name: current_user.username,
        email: current_user.email,
        address: current_user.address,
        city: current_user.city,
        province: current_user.province&.code,
        postal_code: current_user.postal_code
      )
    else
      @customer = Customer.new
    end

    load_cart
    load_tax_preview
  end

  def create
    session[:cart] ||= {}

    if session[:cart].blank?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    if user_signed_in?
      selected_province = Province.find_by(code: checkout_params[:province])

      current_user.update(
        username: checkout_params[:name],
        address: checkout_params[:address],
        city: checkout_params[:city],
        province: selected_province,
        postal_code: checkout_params[:postal_code]
      )

      customer_email = current_user.email
    else
      customer_email = checkout_params[:email].to_s.strip.downcase
    end

    @customer = Customer.find_or_initialize_by(email: customer_email)
    @customer.assign_attributes(checkout_params)
    @customer.email = customer_email

    unless @customer.save
      load_cart
      load_tax_preview
      render :new, status: :unprocessable_entity
      return
    end

    subtotal = cart_subtotal
    rates = tax_rates_for(@customer.province)

    gst_amount = (subtotal * rates[:gst]).round(2)
    pst_amount = (subtotal * rates[:pst]).round(2)
    hst_amount = (subtotal * rates[:hst]).round(2)
    total = (subtotal + gst_amount + pst_amount + hst_amount).round(2)

    stripe_session = nil
    ActiveRecord::Base.transaction do
      @order = @customer.orders.create!(
        subtotal: subtotal,
        gst_amount: gst_amount,
        pst_amount: pst_amount,
        hst_amount: hst_amount,
        total: total,
        status: "pending",
        payment_status: "pending"
      )

      current_cart_products.each do |product|
        quantity = session[:cart][product.id.to_s].to_i
        unit_price = product.price
        line_subtotal = (unit_price * quantity).round(2)

        @order.order_items.create!(
          product: product,
          quantity: quantity,
          unit_price: unit_price,
          subtotal: line_subtotal
        )
      end

      configure_stripe!

      if stripe_configured?
        stripe_session = Stripe::Checkout::Session.create(
          mode: "payment",
          client_reference_id: @order.id.to_s,
          customer_email: @customer.email,
          success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
          cancel_url: checkout_cancel_url,
          line_items: current_cart_products.map do |product|
            quantity = session[:cart][product.id.to_s].to_i

            {
              quantity: quantity,
              price_data: {
                currency: "cad",
                unit_amount: (product.price * 100).to_i,
                product_data: {
                  name: product.name,
                  description: product.description.to_s.truncate(100)
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
      end
    end

    if stripe_session.present?
      redirect_to stripe_session.url, allow_other_host: true
    else
      redirect_to order_path(@order), notice: "Order created without Stripe payment because STRIPE_SECRET_KEY is not configured."
    end
  end

  def success
    session_id = params[:session_id]

    if session_id.blank?
      redirect_to root_path, alert: "Missing Stripe session."
      return
    end

    configure_stripe!

    unless stripe_configured?
      redirect_to cart_path, alert: "Stripe is not configured yet. Please set STRIPE_SECRET_KEY and try again."
      return
    end

    stripe_session = Stripe::Checkout::Session.retrieve(session_id)
    @order = Order.find_by!(stripe_checkout_session_id: stripe_session.id)

    if stripe_session.payment_status == "paid"
      @order.update!(
        status: "paid",
        payment_status: "paid",
        stripe_payment_intent_id: stripe_session.payment_intent
      )

      session[:cart] = {}
      redirect_to order_path(@order), notice: "Payment successful. Your order is now paid."
    else
      redirect_to cart_path, alert: "Payment was not completed."
    end
  end

  def cancel
    redirect_to cart_path, alert: "Payment was canceled."
  end

  private

  def checkout_params
    params.require(:customer).permit(:name, :email, :address, :city, :province, :postal_code)
  end

  def current_cart_products
    Product.where(id: session[:cart].keys)
  end

  def cart_subtotal
    current_cart_products.sum do |product|
      product.price * session[:cart][product.id.to_s].to_i
    end.round(2)
  end

  def load_cart
    @cart_items = current_cart_products.map do |product|
      quantity = session[:cart][product.id.to_s].to_i
      subtotal = (product.price * quantity).round(2)

      {
        product: product,
        quantity: quantity,
        subtotal: subtotal
      }
    end

    @cart_subtotal = @cart_items.sum { |item| item[:subtotal] }.round(2)
  end

  def load_tax_preview
    @tax_preview = tax_preview_for(@customer.province)
  end

  def tax_preview_for(province)
    rates = tax_rates_for(province)
    gst_amount = (@cart_subtotal * rates[:gst]).round(2)
    pst_amount = (@cart_subtotal * rates[:pst]).round(2)
    hst_amount = (@cart_subtotal * rates[:hst]).round(2)

    {
      gst_amount: gst_amount,
      pst_amount: pst_amount,
      hst_amount: hst_amount,
      total: (@cart_subtotal + gst_amount + pst_amount + hst_amount).round(2)
    }
  end

  def tax_rates_for(province)
    case province
    when "ON"
      { gst: 0.0, pst: 0.0, hst: 0.13 }
    when "NB", "NL", "PE"
      { gst: 0.0, pst: 0.0, hst: 0.15 }
    when "NS"
      { gst: 0.0, pst: 0.0, hst: 0.14 }
    when "BC"
      { gst: 0.05, pst: 0.07, hst: 0.0 }
    when "MB"
      { gst: 0.05, pst: 0.07, hst: 0.0 }
    when "SK"
      { gst: 0.05, pst: 0.06, hst: 0.0 }
    when "QC"
      { gst: 0.05, pst: 0.09975, hst: 0.0 }
    else
      { gst: 0.05, pst: 0.0, hst: 0.0 }
    end
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
