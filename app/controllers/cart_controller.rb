class CartController < ApplicationController
  def show
    session[:cart] ||= {}

    product_ids = session[:cart].keys
    products = Product.where(id: product_ids)

    @cart_items = products.map do |product|
      quantity = session[:cart][product.id.to_s]
      {
        product: product,
        quantity: quantity,
        subtotal: product.price * quantity
      }
    end

    @cart_total = @cart_items.sum { |item| item[:subtotal] }
  end

  def add
    session[:cart] ||= {}
    product_id = params[:id].to_s

    if session[:cart][product_id]
      session[:cart][product_id] += 1
    else
      session[:cart][product_id] = 1
    end

    redirect_back fallback_location: root_path, notice: "Product added to cart."
  end
  def update
    session[:cart] ||= {}
    product_id = params[:id].to_s
    quantity = params[:quantity].to_i

    if quantity > 0
      session[:cart][product_id] = quantity
      redirect_to cart_path, notice: "Cart Updated."
    else
      session[:cart].delete(product_id)
      redirect_to cart_path, notice: "Item removed from the cart."
    end
  end
  
  def remove
    session[:cart] ||= {}
    session[:cart].delete(params[:id].to_s)

    redirect_to cart_path, notice: "Product removed from cart."
  end
end