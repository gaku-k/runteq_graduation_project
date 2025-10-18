class CreateProductDrafts < ActiveRecord::Migration[8.0]
  def change
    create_table :product_drafts do |t|
      t.belongs_to :product, null: true, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.string :name
      t.string :country_of_origin
      t.integer :volume
      t.decimal :reference_price
      t.integer :sweet_rating
      t.integer :spicy_rating
      t.integer :bitter_rating
      t.integer :green_rating
      t.integer :fruity_rating
      t.integer :request_type, null: false

      t.timestamps
    end
  end
end
