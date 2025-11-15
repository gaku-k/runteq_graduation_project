# app/mailers/devise_custom_mailer.rb
class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers 
  
  # SendGrid::API::Client のインスタンスを保持
  def sendgrid_client
    @sendgrid_client ||= SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end

  # Deviseのメール送信をフックするプライベートメソッド
  # Deviseは `send_devise_mail` を呼び出すため、このメソッドは残します。
  def send_devise_mail(method, record, opts={})
    # 1. ActionViewでメールボディをレンダリング
    mail = super # 標準のActionMailerの mail メソッドを呼び出し、Deviseのビューをレンダリング
    
    # 2. SendGrid::Mailオブジェクトを構築
    sg_mail = SendGrid::Mail.new
    sg_mail.from = SendGrid::Email.new(email: mail.from.first)
    sg_mail.subject = mail.subject
    
    personalization = SendGrid::Personalization.new
    personalization.add_to(SendGrid::Email.new(email: mail.to.first))
    sg_mail.add_personalization(personalization)
    
    # HTMLボディをセット
    # ActionMailerでレンダリングされたHTMLコンテンツをそのまま使用
    sg_mail.add_content(SendGrid::Content.new(type: 'text/html', value: mail.body.encoded))

    # 3. SendGrid APIに送信 (エラーハンドリングを追加)
    begin
      response = sendgrid_client.client.mail._send.post(request_body: sg_mail.to_json)
      
      # 応答をログに出力して確認
      Rails.logger.info "SendGrid Response: #{response.status_code}"
      Rails.logger.info "SendGrid Headers: #{response.headers}"
      Rails.logger.info "SendGrid Body: #{response.body}"

      # 200/202 以外のステータスコードを処理
      if response.status_code.to_i >= 400
        raise "SendGrid API Error: #{response.status_code}, Body: #{response.body}"
      end
    rescue => e
      # 送信エラーをログに記録
      Rails.logger.error "Mail Send Error: #{e.message}"
      # エラーが発生した場合でも、Deviseの通常のリダイレクトを続行するためにエラーを再発生させない
    end
    
    # 実際にはリダイレクトが行われるため、ここでは mail オブジェクトを返す必要はない
  end

  # Deviseの標準メソッドを上書きし、カスタムメソッドを呼び出すようにする
  def reset_password_instructions(record, token, opts={})
    send_devise_mail(:reset_password_instructions, record, opts)
  end
end