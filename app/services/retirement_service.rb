class RetirementService
  def self.call(offset)
    orders_mass = offset.orders.sum(:mass_g)
    proofs_mass = offset.fulfillment_proofs.sum(:mass_g)

    return unless orders_mass >= offset.mass_g || proofs_mass >= offset.mass_g

    offset.update!(retired: true)
  end
end
