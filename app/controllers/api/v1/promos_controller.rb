module Api
  module V1
    class PromosController < ApplicationController
      before_action :set_product
      before_action :set_promo, only: %i[update destroy]

      def index
        render json: @product.promos
      end

      def create
        @promo = @product.promos.build(promo_params)

        if @promo.save
          render json: @promo, status: :created
        else
          render json: {
            error: "Product promo creation failed",
            details: @promo.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @promo.update(promo_params)
          render json: @promo
        else
          render json: {
            error: "Product promo update failed",
            details: @promo.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        @promo.update(active: false)
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:product_id])
      end

      def set_promo
        @promo = @product.promos.find(params[:id])
      end

      def promo_params
        params.require(:promo).permit(
          :name, :promo_type, :trigger_qty, :free_qty,
          :discount_percentage, :discount_amount, :active
        )
      end
    end
  end
end
