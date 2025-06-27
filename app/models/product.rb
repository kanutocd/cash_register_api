class Product < ApplicationRecord
  validates :code, :name, presence: true, uniqueness: { case_sensitive: false }
  validates :price, presence: true, numericality: { greater_than: 0, numericality: { greater_than: 0 } }

  scope :active, -> { where(active: true) }
end
