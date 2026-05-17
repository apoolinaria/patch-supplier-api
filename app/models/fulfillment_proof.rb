class FulfillmentProof < ApplicationRecord
  belongs_to :offset
  validates :serial_number, presence: true, uniqueness: true
  validates :mass_g, presence: true, numericality: { greater_than: 0 }
  validate :mass_g_within_remaining_capacity

  private

  def mass_g_within_remaining_capacity
    return unless offset && mass_g

    already_proven = offset.fulfillment_proofs.sum(:mass_g)
    remaining = offset.mass_g - already_proven

    if mass_g > remaining
      errors.add(:mass_g, "exceeds remaining capacity of #{remaining}g for this offset")
    end
  end
end
