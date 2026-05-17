class PayoutService
  def self.call(offset)
    return if offset.payout.present?

    Payout.create!(
      project: offset.project,
      offset: offset,
      amount_cents_usd: offset.price_cents_usd,
      status: :pending_approval
    )
  end
end
