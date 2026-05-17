class Payout < ApplicationRecord
  belongs_to :project
  belongs_to :offset
  enum :status, { pending_approval: "pending_approval", completed: "completed" }, default: "pending_approval"

  validates :amount_cents_usd, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :offset, presence: true
end
