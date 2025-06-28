module Api
  module V1
    class CartItemsController < ApplicationController
      before_action :set_cart_item, only: %i[update destroy]

      def index
        @cart_items = CartItem.includes(:product)
        render json: @cart_items.as_json(
          include: { product: { include: :promos } },
          methods: %i[total_price discount_price total_quantity]
        )
      end

      def create
        @cart_item = CartItem.find_or_initialize_by(product_id: cart_item_params[:product_id])

        if @cart_item.persisted?
          @cart_item.quantity += cart_item_params[:quantity].to_i
        else
          @cart_item.assign_attributes(cart_item_params)
        end

        if @cart_item.save
          render json: @cart_item.as_json(
            include: { product: { include: :promos } },
            methods: %i[total_price discount_price total_quantity]
          ), status: :created
        else
          render json: {
            error: "Validation failed",
            details: @cart_item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @cart_item.update(cart_item_params)
          render json: @cart_item.as_json(
            include: { product: { include: :promos } },
            methods: %i[total_price discount_price total_quantity]
          )
        else
          render json: {
            error: "Validation failed",
            details: @cart_item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        @cart_item.destroy
        head :no_content
      end

      def clear
        CartItem.destroy_all
        head :no_content
      end

      def total
        cart_items = CartItem.includes(:product)
        total_amount = cart_items.sum(&:total_price)
        total_discount = cart_items.sum(&:discount_price)
        items_count = cart_items.sum(&:total_quantity)

        render json: {
          subtotal: cart_items.sum { |item| item.quantity * item.product.price },
          total_discount:,
          total: total_amount,
          items_count:
        }
      end

      private

      def set_cart_item
        @cart_item = CartItem.find(params[:id])
      end

      def cart_item_params
        params.require(:cart_item).permit(:product_id, :quantity)
      end
    end
  end
end
