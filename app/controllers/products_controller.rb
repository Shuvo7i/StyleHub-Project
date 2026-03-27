class ProductsController < ApplicationController
    def index
        @filter = params[:filter]
        @products = Product.includes(:category).order(created_at: :desc)
        @products = @products.page(params[:page]).per(12)

    case @filter
    when "on_sale"
      @products = @products.where(on_sale: true)
    when "new"
      @products = @products.where("created_at >= ?", 3.days.ago)
    when "recently_updated"
      @products = @products.where("updated_at >= ?", 3.days.ago)
                           .where("created_at < ?", 3.days.ago)
                           .order(updated_at: :desc)
    else
      @products = @products.order(created_at: :desc)
    end
    if params[:q].present?
      keyword = "%#{params[:q].strip.downcase}%"
      @products = @products.where(
        "LOWER(products.name) LIKE ? OR LOWER(products.description) LIKE ?",
        keyword,
        keyword
      )
  end
  if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    @products = @products.page(params[:page]).per(12)
  end

    def show
        @product = Product.find(params[:id])
    end
end

