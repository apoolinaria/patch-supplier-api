class AddSkuToOffsets < ActiveRecord::Migration[8.1]
  def change
    add_column :offsets, :sku, :string, null: false
    add_column :offsets, :name, :string, null: false

    add_index :offsets, :sku, unique: true
  end
end
