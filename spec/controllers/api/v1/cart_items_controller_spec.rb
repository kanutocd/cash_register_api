require 'rails_helper'

RSpec.describe Api::V1::CartItemsController, type: :controller do
  let(:product) { create(:product, price: 10.0) }

  describe 'GET #index' do
    let!(:cart_item) { create(:cart_item, product: product, quantity: 2) }

    it 'returns all cart items' do
      get :index
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response[0]['quantity']).to eq(2)
    end
  end

  describe 'POST #create' do
    it 'creates a new cart item' do
      expect {
        post :create, params: { cart_item: { product_id: product.id, quantity: 2 } }
      }.to change(CartItem, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'updates existing cart item quantity' do
      existing_item = create(:cart_item, product: product, quantity: 1)
      post :create, params: { cart_item: { product_id: product.id, quantity: 2 } }
      expect(existing_item.reload.quantity).to eq(3)
    end
  end

  describe 'GET #total' do
    let!(:cart_item1) { create(:cart_item, product: product, quantity: 2) }
    let!(:cart_item2) { create(:cart_item, quantity: 1) }

    it 'returns cart totals' do
      get :total
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['items_count']).to eq(3)
      expect(json_response['total'].to_f).to be > 0
      expect(json_response.keys).to contain_exactly('subtotal', 'total', 'total_discount', 'items_count', 'total_free_items')
    end
  end

  describe 'DELETE #clear' do
    let!(:cart_item) { create(:cart_item) }

    it 'clears all cart items' do
      expect {
        delete :clear
      }.to change(CartItem, :count).to(0)
      expect(response).to have_http_status(:no_content)
    end
  end
end
