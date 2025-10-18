class AddProductDraftIdToProductOliveVarieties < ActiveRecord::Migration[8.0]
  def change
    add_column :product_olive_varieties, :product_draft_id, :bigint
    # インデックスを作ることでデータ検索が高速化
    add_index :product_olive_varieties, :product_draft_id
    # 外部キー制約
    add_foreign_key :product_olive_varieties, :product_drafts
  end
end
