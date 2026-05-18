require "rails_helper"

RSpec.describe PayoutService do
  describe ".call" do
    let(:project) { create(:project) }
    let(:offset)  { create(:offset, project: project, price_cents_usd: 300_000, retired: true) }

    context "when no payout exists yet" do
      it "creates a pending_approval payout for the full price" do
        expect { PayoutService.call(offset) }.to change(Payout, :count).by(1)

        payout = Payout.last
        expect(payout.amount_cents_usd).to eq(300_000)
        expect(payout.status).to eq("pending_approval")
        expect(payout.project).to eq(project)
        expect(payout.offset).to eq(offset)
      end
    end

    context "when a payout already exists (idempotency)" do
      before { create(:payout, project: project, offset: offset) }

      it "does not create a duplicate payout" do
        expect { PayoutService.call(offset) }.not_to change(Payout, :count)
      end
    end
  end
end
