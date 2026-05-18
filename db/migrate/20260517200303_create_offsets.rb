class CreateOffsets < ActiveRecord::Migration[8.1]
  def change
    create_table :offsets do |t|
      t.integer :mass_g, null: false
      t.integer :price_cents_usd, null: false
      t.boolean :retired, null: false, default: false

      t.references :project, null: false, foreign_key: true
      t.timestamps
    end
  end
end
