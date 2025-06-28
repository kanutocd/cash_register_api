module Api
  module V1
    # ProductsController handles product-related API requests.
    # It provides endpoints to list, show, create, update, and delete products.
    #
    # @see Product
    # @see Promo
    class ProductsController < ApplicationController
      before_action :set_product, only: %i[show update destroy]

      # GET /api/v1/products
      def index
        @products = Product.active.includes(:promos)
        render json: @products.as_json(include: :promos), status: :ok
      end

      def show
        render json: @product.as_json(include: :promos), status: :ok
      end

      # POST /api/v1/products
      def create
        @product = Product.new(product_params)
        if @product.save
          render json: @product, status: :created
        else
          render json: { error: "Product creation failed",
                        details: @product.errors.full_messages },
                status: :unprocessable_entity
        end
      end

      def update
        if @product.update(product_params)
          render json: @product, status: :ok
        else
          render json: { error: "Product update failed",
                        details: @product.errors.full_messages },
                status: :unprocessable_entity
        end
      end

      def destroy
        @product.update(active: false)
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:code, :name, :price, :active, :description)
      end
    end
  end
end
