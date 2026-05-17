class CreateFulfillmentProofs < ActiveRecord::Migration[8.1]
  def change
    create_table :fulfillment_proofs do |t|
      t.integer :mass_g, null: false
      t.string :serial_number, null: false

      t.references :offset, null: false, foreign_key: true
      t.timestamps
    end
    add_index :fulfillment_proofs, :serial_number, unique: true
  end
end
