# config/initializers/ は Railsアプリ起動時に最初に読み込まれる設定ファイルを置くディレクトリ
Cloudinary.config do |config|
    # この値は.envで確認できる
    config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
    config.api_key    = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
    # HTTPをHTTPSにする
    config.secure     = true
end