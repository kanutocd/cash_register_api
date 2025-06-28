require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe 'GET #index' do
    let!(:active_product) { create(:product, active: true) }
    let!(:inactive_product) { create(:product, active: false) }

    it 'returns only products that are active' do
      get :index
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response[0]['id']).to eq(active_product.id)
    end
  end

  describe 'GET #show' do
    let(:product) { create(:product) }

    it 'returns the product' do
      get :show, params: { id: product.id }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(product.id)
    end

    it 'returns 404 for non-existent product' do
      get :show, params: { id: 99999999999 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { FactoryBot.attributes_for(:product) }

    it 'creates a new product' do
      expect { post :create, params: { product: valid_params } }.to change(Product, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns validation errors for invalid data' do
      post :create, params: { product: { code: '' } }
      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Product creation failed')
    end
  end

  describe 'PUT #update' do
    let(:product) { create(:product) }

    it 'updates the product attributes' do
      put :update, params: { id: product.id, product: { name: 'Updated Name', code: 'ABC123' } }
      expect(response).to have_http_status(:ok)

      expect(product.reload.name).to eq('Updated Name')
      expect(product.reload.code).to eq('ABC123')
    end
  end

  describe 'DELETE #destroy' do
    let(:product) { create(:product) }

    it 'soft deletes the product by setting the active flag to false' do
      delete :destroy, params: { id: product.id }
      expect(response).to have_http_status(:no_content)

      expect(product.reload.active).to eql(false)
    end
  end
end
