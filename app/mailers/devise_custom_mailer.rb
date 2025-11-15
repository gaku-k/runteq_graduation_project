class DeviseCustomMailer < Devise::Mailer
  # DeviseのURLヘルパー(new_user_session_url, edit_user_password_urlを使いたい場合
  include Devise::Controllers::UrlHelpers

  def reset_password_instructions(record, token, opts={})
    # record: 対象ユーザーオブジェクト token: パスワードリセット用トークン opts: 宛名などのオブション
    opts[:to] = record.email
    opts[:subject] = "パスワードリセットの手順"

    # SendGridのAPIを使ってメールを送信
    send_devise_mail(record, token, opts)
  end

  private

  def send_devise_mail(record, token, opts)
    mail_body = render_to_string(
      template: "users/mailer/reset_password_instructions",
      # デフォルトレイアウトを指定。
      layout: "mailer",
      locals: {
        resource: record,
        token: token,
        opts: opts
      }
    )

    # 2. SendGrid::Mailオブジェクトの作成
    mail = SendGrid::Mail.new
    mail.from = SendGrid::Email.new(email: "olivebase.info@gmail.com", name: "olive-base.onrender.com")
    mail.subject = opts[:subject]

    # 宛先の設定
    personalization = SendGrid::Personalization.new
    personalization.add_to = SendGrid::Email.new(email: opts[:to])
    mail.add_personalization(personalization)

    # SendGrid APIを使って送信するメールの本文（コンテンツ）を設定する処理
    # typeでコンテンツの種類、メールクライアントに「この本文はHTMLとして解釈してください」と伝える
    # mail_body: render_to_stringによってレンダリングされていたHTML形式のメール本文
    mail.add_content(SendGrid::Content.new(type: "text/html", value: mail_body))

    # 3. APIクライアントの作成と送信
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    begin
      # 実際にメールを送信するHTTPリクエストを実行
      response = sg.client.mail._send.post(request_body: mail.to_json)
      Rails.logger.info "SendGrid Response: #{response.status_code}"
    rescue Exception => e
      Rails.logger.error "SendGrid Error: #{e.message}"
    end
  end
end