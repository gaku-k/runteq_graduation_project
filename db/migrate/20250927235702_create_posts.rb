class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.bigint :user_id
      t.bigint :product_id
      t.string :product_name
      t.integer :aroma_rating
      t.integer :taste_rating
      t.integer :price_rating
      t.string :body

      t.timestamps
    end
  end
end
