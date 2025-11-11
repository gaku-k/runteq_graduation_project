puts "本番環境用のデータを作っています"

User.find_or_create_by!(email: "olivebase.info@gmail.com") do |user|
  user.name = ENV.fetch("ADMIN_NAME")
  user.password = ENV.fetch("ADMIN_PASSWORD")
  user.password_confirmation = ENV.fetch("ADMIN_PASSWORD")
  user.public_id = "olivebase421"
  user.role = :admin
end
