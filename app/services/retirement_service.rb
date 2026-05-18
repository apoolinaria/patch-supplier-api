class RetirementService
  def self.call(offset)
    orders_mass = offset.orders.sum(:mass_g)
    proofs_mass = offset.fulfillment_proofs.sum(:mass_g)

    # both conditions must hold: all mass sold (orders) AND all mass proven (proofs).
    offset.update!(retired: true) if orders_mass >= offset.mass_g && proofs_mass >= offset.mass_g

    offset
  end
end
