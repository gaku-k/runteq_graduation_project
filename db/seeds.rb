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
Post.create!(
  [
    {
      user_id: 1,
      product_id: 1,
      product_name: "オリーブオイルA",
      aroma_rating: 4,
      taste_rating: 5,
      price_rating: 3,
      body: "香りがとても良い！"
    },
    {
      user_id: 2,
      product_id: 2,
      product_name: "オリーブオイルB",
      aroma_rating: 3,
      taste_rating: 4,
      price_rating: 4,
      body: "味は良いけど少し高いかな"
    }
  ]
)