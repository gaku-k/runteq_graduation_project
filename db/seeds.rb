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
  product_name: "オリーブオイルB",
  body: "こちらは別のサンプルレビューです。",
  aroma_rating: 4,
  taste_rating: 2,
  price_rating: 5
)
file2 = URI.open("https://picsum.photos/301") # 画像URLを変えると別の画像が取れる
post2.images.attach(io: file2, filename: "sample2.jpg", content_type: "image/jpg")

post3 = Post.create!(
  product_name: "オリーブオイルC",
  body: "画像が2枚のサンプルです。",
  aroma_rating: 4,
  taste_rating: 3,
  price_rating: 5
)

# ?random=数字 を使うと毎回違う画像が取得できる
file1 = URI.open("https://picsum.photos/300?random=2")
file2 = URI.open("https://picsum.photos/300?random=3")
post3.images.attach(io: file1, filename: "sample2_1.jpg", content_type: "image/jpg")
post3.images.attach(io: file2, filename: "sample2_2.jpg", content_type: "image/jpg")

# ----------------------
# 画像3枚
# ----------------------
post4 = Post.create!(
  product_name: "オリーブオイルD",
  body: "画像が3枚のサンプルです。",
  aroma_rating: 5,
  taste_rating: 4,
  price_rating: 4
)

file1 = URI.open("https://picsum.photos/300?random=4")
file2 = URI.open("https://picsum.photos/300?random=5")
file3 = URI.open("https://picsum.photos/300?random=6")
post4.images.attach(io: file1, filename: "sample3_1.jpg", content_type: "image/jpg")
post4.images.attach(io: file2, filename: "sample3_2.jpg", content_type: "image/jpg")
post4.images.attach(io: file3, filename: "sample3_3.jpg", content_type: "image/jpg")

# ----------------------
# 画像4枚
# ----------------------
post5 = Post.create!(
  product_name: "オリーブオイルE",
  body: "画像が4枚のサンプルです。",
  aroma_rating: 2,
  taste_rating: 5,
  price_rating: 3
)

file1 = URI.open("https://picsum.photos/300?random=7")
file2 = URI.open("https://picsum.photos/300?random=8")
file3 = URI.open("https://picsum.photos/300?random=9")
file4 = URI.open("https://picsum.photos/300?random=10")
post5.images.attach(io: file1, filename: "sample4_1.jpg", content_type: "image/jpg")
post5.images.attach(io: file2, filename: "sample4_2.jpg", content_type: "image/jpg")
post5.images.attach(io: file3, filename: "sample4_3.jpg", content_type: "image/jpg")
post5.images.attach(io: file4, filename: "sample4_4.jpg", content_type: "image/jpg")