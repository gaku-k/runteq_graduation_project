class RemoveRatingsFromProductsAndProductDrafts < ActiveRecord::Migration[8.0]
  # ProductRatingsテーブルの追加に伴い、Product1レコードにつき一つずつしかデータが入らなかったカラムは不要となる
  def change
    # Products テーブルから削除
    remove_column :products, :sweet_rating, :integer
    remove_column :products, :spicy_rating, :integer
    remove_column :products, :bitter_rating, :integer
    remove_column :products, :green_rating, :integer
    remove_column :products, :fruity_rating, :integer

    # ProductDrafts テーブルから削除
    remove_column :product_drafts, :sweet_rating, :integer
    remove_column :product_drafts, :spicy_rating, :integer
    remove_column :product_drafts, :bitter_rating, :integer
    remove_column :product_drafts, :green_rating, :integer
    remove_column :product_drafts, :fruity_rating, :integer
  end
end
