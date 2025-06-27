require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    subject { build(:product) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:code).ignoring_case_sensitivity }
    it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
  end

  describe 'scopes' do
    let(:active_product) { create(:product, active: true) }
    let(:inactive_product) { create(:product, active: false) }

    it 'returns only active products' do
      expect(Product.active).to include(active_product)
      expect(Product.active).not_to include(inactive_product)
    end
  end
end
