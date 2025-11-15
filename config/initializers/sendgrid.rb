# SendGridのActionMailerアダプターをロード
# これにより、ActionMailerが :sendgrid delivery_methodを認識できるようになる。
ActionMailer::Base.add_delivery_method :sendgrid, Mail::SendGrid, api_key: ENV['SENDGRID_API_KEY']