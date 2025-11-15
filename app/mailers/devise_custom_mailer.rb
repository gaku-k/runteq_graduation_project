# app/mailers/devise_custom_mailer.rb
class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers 
  
  # SendGrid::API::Client のインスタンスを保持
  def sendgrid_client
    @sendgrid_client ||= SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end

  # Deviseのメール送信をフックするプライベートメソッド
  def reset_password_instructions(record, token, opts={})
    # Devise::Mailerが提供する headers_for は使用する。
    headers = headers_for(:reset_password_instructions, record, opts)
    
    mail_message = mail(to: record.email, 
                        subject: "パスワードリセットの手順",
                        template_name: 'reset_password_instructions')

    # SendGrid::Mailオブジェクトを構築
    sg_mail = SendGrid::Mail.new
    sg_mail.from = SendGrid::Email.new(email: mail_message.from.first)
    sg_mail.subject = mail_message.subject
    
    personalization = SendGrid::Personalization.new
    personalization.add_to(SendGrid::Email.new(email: mail_message.to.first))
    sg_mail.add_personalization(personalization)
    
    # HTMLボディをセット (レンダリングされたHTMLコンテンツを取得)
    html_content = mail_message.body.encoded
    sg_mail.add_content(SendGrid::Content.new(type: 'text/html', value: html_content))

    # SendGrid APIに送信 (エラーハンドリングを追加)
    begin
      response = sendgrid_client.client.mail._send.post(request_body: sg_mail.to_json)
      
      Rails.logger.info "SendGrid Response: Status=#{response.status_code}, Body=#{response.body}"

      if response.status_code.to_i >= 400
        # APIエラーはログに記録するが、Deviseがリダイレクトを続けるために例外は発生させない
        Rails.logger.error "SENDGRID API FAILED: #{response.status_code}, Body: #{response.body}"
      end
    rescue => e
      Rails.logger.error "Mail Send Exception: #{e.message}"
    end
    
    # Deviseがリダイレクトを処理できるように、このメソッドは mail_message オブジェクトを返す必要がある
    mail_message
  end
end