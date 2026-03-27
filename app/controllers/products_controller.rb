class ProductsController < ApplicationController
    def index
        @filter = params[:filter]
        @products = Product.includes(:category).order(created_at: :desc)

    case @filter
    when "on_sale"
      @products = @products.where(on_sale: true)
    when "new"
      @products = @products.where("created_at >= ?", 3.days.ago)
    when "recently_updated"
      @products = @products.where("updated_at >= ?", 3.days.ago)
                           .where("created_at < ?", 3.days.ago)
                           .order(updated_at: :desc)
    end
  end

    def show
        @product = Product.find(params[:id])
    end
end

