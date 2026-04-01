class CheckoutController < ApplicationController
  def new
    session[:cart] ||= {}

    if session[:cart].blank?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    @customer = Customer.new
    load_cart
  end

  def create
    session[:cart] ||= {}

    if session[:cart].blank?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    @customer = Customer.find_or_initialize_by(email: checkout_params[:email].to_s.strip.downcase)
    @customer.assign_attributes(checkout_params)

    unless @customer.save
      load_cart
      render :new, status: :unprocessable_entity
      return
    end

    subtotal = cart_subtotal
    rates = tax_rates_for(@customer.province)

    gst_amount = (subtotal * rates[:gst]).round(2)
    pst_amount = (subtotal * rates[:pst]).round(2)
    hst_amount = (subtotal * rates[:hst]).round(2)
    total = (subtotal + gst_amount + pst_amount + hst_amount).round(2)

    ActiveRecord::Base.transaction do
      @order = @customer.orders.create!(
        subtotal: subtotal,
        gst_amount: gst_amount,
        pst_amount: pst_amount,
        hst_amount: hst_amount,
        total: total,
        status: "paid"
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
    end

    session[:cart] = {}
    redirect_to order_path(@order), notice: "Order placed successfully."
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
end