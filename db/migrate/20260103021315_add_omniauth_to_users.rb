class AddOmniauthToUsers < ActiveRecord::Migration[8.1]
  # Googleなどの外部サービスでログインする場合、「どのサービス（provider）の」「どのID（uid）か」をデータベースに保存して、次回ログイン時に同じユーザーであることを特定する必要がある
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    # providerとuidの組み合わせを一意にする
    add_index :users, [ :provider, :uid ], unique: true
  end
end
