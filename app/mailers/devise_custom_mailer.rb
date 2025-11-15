# app/mailers/devise_custom_mailer.rb
class DeviseCustomMailer < Devise::Mailer
  # DeviseのURLヘルパーを使いたい場合
  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers 

  # Deviseのデフォルトメソッドをオーバーライド
  # バージョンによっては第3引数 (opts) が渡されないケースがあるらしい。Deviseの最新バージョンに対応するため、*args で予期しない引数をすべて受け取る
  def reset_password_instructions(record, token, *args)
    # ActionMailerの mail メソッドを使って送信
    mail to: record.email, 
         subject: "パスワードリセットの手順",
         # Deviseがレンダリングするビューを指定
         template_name: "reset_password_instructions"
  end

  # Fromアドレスを明示的に指定する場合
  def from(opts)
    "olivebase.info@gmail.com"
  end
end