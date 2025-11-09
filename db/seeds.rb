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
#
# 環境ごとのseedを呼び出す
# load(...)：指定したファイルをそのまま実行する
# Rails.root に "db/seeds/〇〇.rb" をつなげて、ファイルの絶対パスを作る
# "#{Rails.env.downcase}"：現在のRails環境（development, production, testなど）を小文字で取得
# load(Rails.root.join("db/seeds/#{Rails.env.downcase}.rb"))
# 上のように書いていたが、フリープランのRenderではshellが使えないのでこのファイルを実行できない.
load(Rails.root.join("db/seeds/development.rb"))
