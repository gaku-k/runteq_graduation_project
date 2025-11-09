# このタスクはデプロイ時にadminユーザーを作成するために使用する
# renderの
namespace :seed do
  desc "Renderでプロダクション用シードを実行する"
  task production: :environment do
    load Rails.root.join("db/seeds/production.rb")
  end
end
