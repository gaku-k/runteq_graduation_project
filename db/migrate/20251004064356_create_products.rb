class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :country_of_origin
      t.integer :volume
      t.decimal :reference_price
      t.integer :sweet_rating
      t.integer :spicy_rating
      t.integer :bitter_rating
      t.integer :green_rating
      t.integer :fruity_rating

      t.timestamps
    end
  end
end
