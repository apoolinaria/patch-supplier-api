class Offset < ApplicationRecord
  belongs_to :project
  # specs says one and only one order per offset but the seed data has multiple orders per offset, so changing the relationship to one to many
  has_many :orders, dependent: :destroy
  has_many :fulfillment_proofs, dependent: :destroy
  has_one :payout, dependent: :destroy

  validates :mass_g, presence: true, numericality: { greater_than: 0 }
  validates :price_cents_usd, presence: true, numericality: { greater_than: 0 }
end
