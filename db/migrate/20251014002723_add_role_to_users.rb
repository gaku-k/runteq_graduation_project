class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    # 文法的には add_column テーブル名, カラム名, データ型, オプション(ハッシュ)
    # add_column(:users, :role, :integer, { default: 0, null: false }) 
    add_column :users, :role, :integer, default: 0, null: false
  end
end
