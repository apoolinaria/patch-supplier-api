class AddApiKeyToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :api_key, :string, null: false
    add_index :projects, :api_key, unique: true
  end
end
