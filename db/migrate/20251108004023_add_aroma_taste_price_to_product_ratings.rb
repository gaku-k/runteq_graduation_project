class AddAromaTastePriceToProductRatings < ActiveRecord::Migration[8.1]
  def change
    add_column :product_ratings, :aroma, :integer
    add_column :product_ratings, :taste, :integer
    add_column :product_ratings, :price, :integer
  end
end
