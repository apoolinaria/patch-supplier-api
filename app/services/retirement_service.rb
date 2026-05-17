class RetirementService
  def self.call(offset)
    orders_mass = offset.orders.sum(:mass_g)
    proofs_mass = offset.fulfillment_proofs.sum(:mass_g)

    offset.update!(retired: true) if orders_mass >= offset.mass_g && proofs_mass >= offset.mass_g

    offset
  end
end
