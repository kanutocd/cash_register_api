require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'validations' do
    it { should belong_to(:product) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    context 'uniqueness' do
      subject { build(:cart_item) }
      it { should validate_uniqueness_of(:product_id) }
    end
  end

  describe 'associations' do
    it { should belong_to(:product) }
  end

  let(:product) { create(:product, price: 100.0) }
  let(:cart_item) { create(:cart_item, product: product, quantity: 2) }

  context 'without promotion' do
    describe '#total_price' do
      it 'calculates total price with no changes' do
        expect(cart_item.total_price).to eq(200)
      end
    end

    describe '#discount_price' do
      it 'returns zero discount price' do
        expect(cart_item.discount_price).to eq(0)
      end
    end

    describe '#total_quantity' do
      it 'returns the quantity with no changes' do
        expect(cart_item.total_quantity).to eq(2)
      end
    end
  end

  context 'with promo' do
    before do
      cart_item.product = promo.product
    end

    context 'buy_x_get_y_free' do
      let(:promo) { create(:promo, product:, promo_type: 'buy_x_get_y_free', trigger_qty: 2, free_qty: 1) }

      describe '#total_quantity' do
        it 'returns the total quantity including free items' do
          expect(cart_item.total_quantity).to eq(3)
        end
      end

      describe '#total_price' do
        it 'returns the total price without free items' do
          expect(cart_item.total_price).to eq(200)
        end
      end

      describe '#discount_amount' do
        it 'returns the correct discount amount based on the free items' do
          expect(cart_item.discount_price).to eq(100)
        end
      end
    end

    context 'fixed_discount' do
      let(:promo) { create(:promo, product:, promo_type: 'fixed_discount', discount_amount: 50, trigger_qty: 2) }

      describe '#total_quantity' do
        it 'returns the same total quantity' do
          expect(cart_item.total_quantity).to eq(2)
        end
      end

      describe '#total_price' do
        it 'returns total price minus the discount' do
          expect(cart_item.total_price).to eq(100)
        end
      end

      describe '#discount_amount' do
        it 'returns the correct discount amount' do
          expect(cart_item.discount_price).to eq(100)
        end
      end
    end
  end
end
