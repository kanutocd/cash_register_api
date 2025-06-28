require 'rails_helper'

RSpec.describe Promo, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:promo_type) }
    it { should validate_inclusion_of(:promo_type).in_array(Promo::PROMO_TYPES) }
    it { should validate_presence_of(:trigger_qty) }
    it { should validate_numericality_of(:trigger_qty).only_integer.is_greater_than(0) }

    context "name uniqueness" do
      subject { build(:promo, product: create(:product)) }
      it { should validate_uniqueness_of(:name).scoped_to(:product_id).ignoring_case_sensitivity }
    end

    context "when promo_type is buy_x_get_y_free" do
      subject { build(:promo, :buy_x_get_y_free) }

      it { should validate_numericality_of(:free_qty).only_integer.is_greater_than_or_equal_to(0) }
    end

    context "when promo_type is percentage_discount" do
      subject { build(:promo, :percentage_discount) }

      it { should validate_numericality_of(:discount_percentage).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    end

    context "when promo_type is fixed_discount" do
      subject { build(:promo, :fixed_discount) }

      it { should validate_numericality_of(:discount_amount).is_greater_than_or_equal_to(0) }
    end
  end

  describe 'associations' do
    it { should belong_to(:product) }
  end


  describe "scopes" do
    describe ".active" do
      it "returns only active promos" do
        active_promo = create(:promo, active: true)
        inactive_promo = create(:promo, active: false)

        expect(Promo.active).to include(active_promo)
        expect(Promo.active).not_to include(inactive_promo)
      end
    end
  end

  describe "#apply_discount" do
    let(:promo) { create(:promo, active: true) }
    let(:quantity) { 5 }
    let(:unit_price) { 10.0 }

    context "when promo is not applicable" do
      it "returns total without discount and no free items" do
        allow(promo).to receive(:active?).and_return(false)

        result = promo.apply_discount(quantity, unit_price)

        expect(result).to eq({ total: 50.0, discount: 0, free_items: 0 })
      end
    end

    context "when promo is applicable" do
      before do
        allow(promo).to receive(:active?).and_return(true)
        allow(promo).to receive(:trigger_qty).and_return(3)
      end

      context "when promo type is buy_x_get_y_free" do
        before do
          promo.promo_type = "buy_x_get_y_free"
          promo.free_qty = 2
        end

        it "applies buy_x_get_y_free discount" do
          result = promo.apply_discount(quantity, unit_price)

          expect(result).to eq({ total: 50.0, discount: 0, free_items: 2 })
        end
      end

      context "when promo type is percentage_discount" do
        before do
          promo.promo_type = "percentage_discount"
          promo.discount_percentage = 20
        end

        it "applies percentage_discount" do
          result = promo.apply_discount(quantity, unit_price)

          expect(result).to eq({ total: 40.0, discount: 10.0, free_items: 0 })
        end
      end

      context "when promo type is fixed_discount" do
        before do
          promo.promo_type = "fixed_discount"
          promo.discount_amount = 1.0
        end

        it "applies fixed_discount" do
          result = promo.apply_discount(quantity, unit_price)

          expect(result).to eq({ total: 45.0, discount: 5.0, free_items: 0 })
        end
      end
    end
  end
end
