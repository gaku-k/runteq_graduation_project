class AddStatusToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :status, :integer, default: 0, null: false
  end
end
