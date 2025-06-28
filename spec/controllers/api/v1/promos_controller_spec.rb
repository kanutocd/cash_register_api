require 'rails_helper'

RSpec.describe Api::V1::PromosController, type: :controller do
  let!(:product) { create(:product) }
  let!(:promo) { create(:promo, product: product) }

  it 'returns all promos for a product' do
    get :index, params: { product_id: product.id }
    expect(response).to have_http_status(:ok)

    json_response = JSON.parse(response.body)
    expect(json_response.length).to eq(1)
    expect(json_response[0]['id']).to eq(promo.id)
  end

  describe 'POST #create' do
    let(:valid_params) { FactoryBot.attributes_for(:promo, product_id: product.id) }

    it 'creates a new promo' do
      expect { post :create, params: { product_id: product.id, promo: valid_params } }.to change(Promo, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns validation errors for invalid data' do
      post :create, params: { product_id: product.id, promo: { name: '' } }
      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Product promo creation failed')
      expect(json_response['details']).to include("Name can't be blank")
    end
  end

  describe 'PUT #update' do
    let(:update_params) { { name: 'Updated Promo' } }

    it 'updates the promo attributes' do
      put :update, params: { product_id: product.id, id: promo.id, promo: update_params }
      expect(response).to have_http_status(:ok)

      promo.reload
      expect(promo.name).to eq('Updated Promo')
    end

    it 'returns validation errors for invalid data' do
      put :update, params: { product_id: product.id, id: promo.id, promo: { name: '' } }
      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Product promo update failed')
      expect(json_response['details']).to include("Name can't be blank")
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the promo' do
      delete :destroy, params: { product_id: product.id, id: promo.id }
      expect(response).to have_http_status(:no_content)
      expect(promo.reload.active).to eql(false)
    end
  end
end
