class AddNewOliveVarietyIdsToProductDrafts < ActiveRecord::Migration[8.0]
  # rejectアクション時に新規オリーブ品種を削除するため、ProductDraftに新規作成されたOliveVarietyのIDを保存するカラムを追加する
  def change
    add_column :product_drafts, :new_olive_variety_ids, :jsonb, default: []
  end
end
