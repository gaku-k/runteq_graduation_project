class AddPublicIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :public_id, :string, null: false

    # データベースレベルでの一意性制約と検索最適化のためのインデックスを追加
    add_index :users, :public_id, unique: true
  end
end
