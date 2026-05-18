class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.integer :mass_g, null: false

      t.references :offset, null: false, foreign_key: true

      t.timestamps
    end
  end
end
