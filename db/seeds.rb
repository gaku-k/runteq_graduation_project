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

# ----------------------
# 商品サンプルデータ
# ----------------------
Product.destroy_all

# 品種をあらかじめ作成
variety1 = OliveVariety.create!(name: "アルベキーナ")
variety2 = OliveVariety.create!(name: "ピクアル")

product0 = Product.create!(
  name: "商品:オリーブオイル",
  country_of_origin: "トルコ",
  volume: 600,
  reference_price: 2300,
  sweet_rating: 4,
  spicy_rating: 1,
  bitter_rating: 2,
  green_rating: 3,
  fruity_rating: 5
)

# 関連付け（中間テーブルに自動でレコードが作られる）
product0.olive_varieties << [ variety1, variety2 ]

file1 = URI.open("https://picsum.photos/300?random=7")
file2 = URI.open("https://picsum.photos/300?random=8")
file3 = URI.open("https://picsum.photos/300?random=9")
file4 = URI.open("https://picsum.photos/300?random=10")
product0.images.attach(io: file1, filename: "sample4_1.jpg", content_type: "image/jpg")
product0.images.attach(io: file2, filename: "sample4_2.jpg", content_type: "image/jpg")
product0.images.attach(io: file3, filename: "sample4_3.jpg", content_type: "image/jpg")
product0.images.attach(io: file4, filename: "sample4_4.jpg", content_type: "image/jpg")

product1 = Product.create!(
  name: "商品:オリーブオイルA",
  country_of_origin: "スペイン",
  volume: 250,
  reference_price: 2000,
  sweet_rating: 4,
  spicy_rating: 3,
  bitter_rating: 5,
  green_rating: 4,
  fruity_rating: 2
)

product2 = Product.create!(
  name: "商品:オリーブオイルB",
  country_of_origin: "イタリア",
  volume: 250,
  reference_price: 1500,
  sweet_rating: 3,
  spicy_rating: 1,
  bitter_rating: 4,
  green_rating: 5,
  fruity_rating: 3
)

file1 = URI.open("https://picsum.photos/300?random=2")
file2 = URI.open("https://picsum.photos/300?random=3")
product2.images.attach(io: file1, filename: "sample2_1.jpg", content_type: "image/jpg")
product2.images.attach(io: file2, filename: "sample2_2.jpg", content_type: "image/jpg")

product3 = Product.create!(
  name: "商品:オリーブオイルC",
  country_of_origin: "ポルトガル",
  volume: 260,
  reference_price: 1400,
  sweet_rating: 3,
  spicy_rating: 2,
  bitter_rating: 3,
  green_rating: 5,
  fruity_rating: 5
)

file1 = URI.open("https://picsum.photos/300?random=4")
file2 = URI.open("https://picsum.photos/300?random=5")
file3 = URI.open("https://picsum.photos/300?random=6")
product3.images.attach(io: file1, filename: "sample3_1.jpg", content_type: "image/jpg")
product3.images.attach(io: file2, filename: "sample3_2.jpg", content_type: "image/jpg")
product3.images.attach(io: file3, filename: "sample3_3.jpg", content_type: "image/jpg")

product4 = Product.create!(
  name: "商品:オリーブオイルD",
  country_of_origin: "トルコ",
  volume: 600,
  reference_price: 2300,
  sweet_rating: 4,
  spicy_rating: 1,
  bitter_rating: 2,
  green_rating: 3,
  fruity_rating: 5
)

file1 = URI.open("https://picsum.photos/300?random=7")
file2 = URI.open("https://picsum.photos/300?random=8")
file3 = URI.open("https://picsum.photos/300?random=9")
file4 = URI.open("https://picsum.photos/300?random=10")
product4.images.attach(io: file1, filename: "sample4_1.jpg", content_type: "image/jpg")
product4.images.attach(io: file2, filename: "sample4_2.jpg", content_type: "image/jpg")
product4.images.attach(io: file3, filename: "sample4_3.jpg", content_type: "image/jpg")
product4.images.attach(io: file4, filename: "sample4_4.jpg", content_type: "image/jpg")

# 画像一枚で縦横4:3になるか
product5 = Product.create!(
  name: "商品:オリーブオイルE",
  country_of_origin: "イタリア",
  volume: 260,
  reference_price: 2300,
  sweet_rating: 5,
  spicy_rating: 1,
  bitter_rating: 2,
  green_rating: 5,
  fruity_rating: 1
)

file1 = URI.open("https://picsum.photos/300?random=2")
product5.images.attach(io: file1, filename: "sample2_2.jpg", content_type: "image/jpg")
