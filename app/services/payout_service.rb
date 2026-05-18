class PayoutService
  def self.call(offset)
    return if offset.payout.present?

    # Status starts at pending_approval so the finance team has an explicit approval step
    # before the payout is considered finalized.
    Payout.create!(
      project: offset.project,
      offset: offset,
      amount_cents_usd: offset.price_cents_usd,
      status: :pending_approval
    )
  end
end
