class Product < ApplicationRecord
  has_many :promos, dependent: :destroy
  has_many :cart_items, dependent: :destroy

  validates :code, :name, presence: true, uniqueness: { case_sensitive: false }
  validates :price, presence: true, numericality: { greater_than: 0, numericality: { greater_than: 0 } }

  scope :active, -> { where(active: true) }

  def current_promo
    promos.active.order(created_at: :desc).first
  end
end
