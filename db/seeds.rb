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

# データのクリーンアップ
ProductOliveVariety.destroy_all
ProductDraft.destroy_all
Product.destroy_all
Post.destroy_all
OliveVariety.destroy_all

# Userレコードの作成/取得
# Userレコードの作成/取得（find_or_create_by! を使うと2回目以降の実行時に重複作成を防げる）
user = User.find_or_create_by!(email: "test@example.com") do |u|
  u.password = "password"
  u.name = "gaku"
  u.role = :admin # または u.role = 1 でもDB上は問題ない
end

user2 = User.find_or_create_by!(email: "hogehoge@gmail.com") do |u|
  u.password = "password"
  u.name = "らんてくん"
  u.role = 0
end

# ----------------------
# 商品サンプルデータ
# ----------------------

# 品種をあらかじめ作成
variety1 = OliveVariety.find_or_create_by!(name: "アルベキーナ")
variety2 = OliveVariety.find_or_create_by!(name: "ピクアル")

product0 = Product.create!(
  status: :published,
  name: "商品:オリーブオイル",
  country_of_origin: "トルコ",
  volume: 600,
  reference_price: 2300,
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
  status: :published,
  name: "商品:オリーブオイルA",
  country_of_origin: "スペイン",
  volume: 250,
  reference_price: 2000,
)

product2 = Product.create!(
  status: :published,
  name: "商品:オリーブオイルB",
  country_of_origin: "イタリア",
  volume: 250,
  reference_price: 1500,
)

file1 = URI.open("https://picsum.photos/300?random=2")
file2 = URI.open("https://picsum.photos/300?random=3")
product2.images.attach(io: file1, filename: "sample2_1.jpg", content_type: "image/jpg")
product2.images.attach(io: file2, filename: "sample2_2.jpg", content_type: "image/jpg")

product3 = Product.create!(
  status: :published,
  name: "商品:オリーブオイルC",
  country_of_origin: "ポルトガル",
  volume: 260,
  reference_price: 1400,
)

file1 = URI.open("https://picsum.photos/300?random=4")
file2 = URI.open("https://picsum.photos/300?random=5")
file3 = URI.open("https://picsum.photos/300?random=6")
product3.images.attach(io: file1, filename: "sample3_1.jpg", content_type: "image/jpg")
product3.images.attach(io: file2, filename: "sample3_2.jpg", content_type: "image/jpg")
product3.images.attach(io: file3, filename: "sample3_3.jpg", content_type: "image/jpg")

product4 = Product.create!(
  status: :published,
  name: "商品:オリーブオイルD",
  country_of_origin: "トルコ",
  volume: 600,
  reference_price: 2300,
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
  status: :published,
  name: "商品:オリーブオイルE",
  country_of_origin: "イタリア",
  volume: 260,
  reference_price: 2300,
)

file1 = URI.open("https://picsum.photos/300?random=2")
product5.images.attach(io: file1, filename: "sample2_2.jpg", content_type: "image/jpg")

# ----------------------
# 投稿サンプルデータ
# ----------------------
# 1件目
post1 = Post.create!(
  user: user,
  product_id: product0.id,
  product_name: product0.name,
  body: "これはサンプルレビューです。",
)
# 幅300pxのランダムなダミー画像をダウンロードして file に格納
file1 = URI.open("https://picsum.photos/300")
# ActiveStorage の has_many_attached :images に画像を追加する処理
# io: file → ダウンロードした画像データを渡す
# content_type: "image/jpg" → MIMEタイプ（ブラウザが画像と認識するための情報）
post1.images.attach(io: file1, filename: "sample1.jpg", content_type: "image/jpg")

product_rating = ProductRating.find_or_initialize_by(
  user: user,
  product: product0
)

# 評価値の設定 (0から5の範囲を想定)
product_rating.aroma = 4
product_rating.taste = 5
product_rating.price = 3

# データベースに保存（作成または更新）
if product_rating.save
  puts "✅ ProductRating for User ID #{user.id} and Product ID #{product0.id} has been saved/updated."
else
  puts "❌ Error saving ProductRating: #{product_rating.errors.full_messages.join(', ')}"
end


# 2件目
post2 = Post.create!(
  user: user,
  product_id: product0.id,
  product_name: product0.name,
  body: "こちらは別のサンプルレビューです。",
)

file2 = URI.open("https://picsum.photos/301") # 画像URLを変えると別の画像が取れる
post2.images.attach(io: file2, filename: "sample2.jpg", content_type: "image/jpg")

post3 = Post.create!(
  user: user,
  product_id: product1.id,
  product_name: product1.name,
  body: "画像が2枚のサンプルです。",
)

# ?random=数字 を使うと毎回違う画像が取得できる
file1 = URI.open("https://picsum.photos/300?random=2")
file2 = URI.open("https://picsum.photos/300?random=3")
post3.images.attach(io: file1, filename: "sample2_1.jpg", content_type: "image/jpg")
post3.images.attach(io: file2, filename: "sample2_2.jpg", content_type: "image/jpg")

product_rating = ProductRating.find_or_initialize_by(
  user: user,
  product: product1
)

# 評価値の設定 (0から5の範囲を想定)
product_rating.aroma = 2
product_rating.taste = 1
product_rating.price = 5

# データベースに保存（作成または更新）
if product_rating.save
  puts "✅ ProductRating for User ID #{user.id} and Product ID #{product0.id} has been saved/updated."
else
  puts "❌ Error saving ProductRating: #{product_rating.errors.full_messages.join(', ')}"
end
# ----------------------
# 画像3枚
# ----------------------
post4 = Post.create!(
  user: user,
  product_id: product1.id,
  product_name: product1.name,
  body: "画像が3枚のサンプルです。",
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
  user: user,
  body: "画像が4枚のサンプルです。",
)

file1 = URI.open("https://picsum.photos/300?random=7")
file2 = URI.open("https://picsum.photos/300?random=8")
file3 = URI.open("https://picsum.photos/300?random=9")
file4 = URI.open("https://picsum.photos/300?random=10")
post5.images.attach(io: file1, filename: "sample4_1.jpg", content_type: "image/jpg")
post5.images.attach(io: file2, filename: "sample4_2.jpg", content_type: "image/jpg")
post5.images.attach(io: file3, filename: "sample4_3.jpg", content_type: "image/jpg")
post5.images.attach(io: file4, filename: "sample4_4.jpg", content_type: "image/jpg")
