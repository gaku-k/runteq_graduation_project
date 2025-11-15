# app/mailers/devise_custom_mailer.rb
class DeviseCustomMailer < Devise::Mailer
  # DeviseのURLヘルパーを使いたい場合
  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers 

  # Deviseのデフォルトメソッドをオーバーライド
  def reset_password_instructions(record, token, opts={})
    # headers_for, mail メソッドは Devise と ActionMailer の標準機能
    # これにより、ActionMailerが config/environments/production.rb の設定に従って送信する
    mail headers_for(:reset_password_instructions, record, opts).merge(to: record.email, subject: "パスワードリセットの手順")
  end

  # Fromアドレスを明示的に指定する場合
  def from(opts)
    "olivebase.info@gmail.com"
  end
end