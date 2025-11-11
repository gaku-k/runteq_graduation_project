# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

# このタスクはデプロイ時にadminユーザーを作成するために使用する
# renderのStart Commandで設定している
namespace :seed do
  desc "Renderでプロダクション用シードを実行する"
  task production: :environment do
    load Rails.root.join("db/seeds/production.rb")
  end
end
