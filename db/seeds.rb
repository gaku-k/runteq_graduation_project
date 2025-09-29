# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
# Rubyの標準ライブラリを読み込む
# URI.open("URL")でインターネット上のファイルを開いて取得できるようにする
require "open-uri"

# データベースの posts テーブルにあるデータを全削除。
Post.destroy_all

# 1件目
post1 = Post.create!(
  product_name: "オリーブオイルA",
  body: "これはサンプルレビューです。",
  aroma_rating: 3,
  taste_rating: 3,
  price_rating: 3
)
# 幅300pxのランダムなダミー画像をダウンロードして file に格納
file1 = URI.open("https://picsum.photos/300")
# ActiveStorage の has_many_attached :images に画像を追加する処理
# io: file → ダウンロードした画像データを渡す
# content_type: "image/jpg" → MIMEタイプ（ブラウザが画像と認識するための情報）
post1.images.attach(io: file1, filename: "sample1.jpg", content_type: "image/jpg")

# 2件目
post2 = Post.create!(
  product_name: "トマトソースB",
  body: "こちらは別のサンプルレビューです。",
  aroma_rating: 4,
  taste_rating: 2,
  price_rating: 5
)
file2 = URI.open("https://picsum.photos/301") # 画像URLを変えると別の画像が取れる
post2.images.attach(io: file2, filename: "sample2.jpg", content_type: "image/jpg")