class CreatePayouts < ActiveRecord::Migration[8.1]
  def change
    create_table :payouts do |t|
      t.references :project, null: false, foreign_key: true
      t.references :offset, null: false, foreign_key: true, index: { unique: true }
      t.integer :amount_cents_usd, null: false
      t.string :status, null: false, default: "pending_approval"

      t.timestamps
    end
  end
end
