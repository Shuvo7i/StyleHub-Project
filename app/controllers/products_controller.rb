class ProductsController < ApplicationController
    def index
        @products = Product.includes(:category).order(created_at: :desc)
    end
    def show
        @product = Product.find(params[:id])
    end
end

