require "rails_helper"

RSpec.describe RetirementService do
  describe ".call" do
    let(:offset) { create(:offset, mass_g: 10_000_000) }

    context "when both orders and proofs cover the full mass" do
      before do
        create(:order, offset: offset, mass_g: 10_000_000)
        create(:fulfillment_proof, offset: offset, mass_g: 10_000_000)
      end

      it "marks the offset as retired" do
        RetirementService.call(offset)
        expect(offset.reload.retired?).to be true
      end

      it "returns the offset" do
        result = RetirementService.call(offset)
        expect(result).to eq(offset)
      end
    end

    context "when orders cover full mass but proofs do not" do
      before do
        create(:order, offset: offset, mass_g: 10_000_000)
        create(:fulfillment_proof, offset: offset, mass_g: 5_000_000)
      end

      it "does not retire the offset" do
        RetirementService.call(offset)
        expect(offset.reload.retired?).to be false
      end
    end

    context "when proofs cover full mass but orders do not" do
      before do
        create(:order, offset: offset, mass_g: 5_000_000)
        create(:fulfillment_proof, offset: offset, mass_g: 10_000_000)
      end

      it "does not retire the offset" do
        RetirementService.call(offset)
        expect(offset.reload.retired?).to be false
      end
    end

    context "when there are no orders or proofs" do
      it "does not retire the offset" do
        RetirementService.call(offset)
        expect(offset.reload.retired?).to be false
      end
    end
  end
end
