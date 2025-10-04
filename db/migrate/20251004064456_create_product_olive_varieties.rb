class CreateProductOliveVarieties < ActiveRecord::Migration[8.0]
  def change
    create_table :product_olive_varieties do |t|
      t.integer :product_id
      t.integer :olive_variety_id

      t.timestamps
    end
  end
end
