# Mailer のメソッド名と View のファイル名はリンクしている。そのメソッド内で作ったインスタンス変数を View に渡すために、Mailer が存在する
class AdminMailer < ApplicationMailer
  def notification_email(draft_count, contact_count)
    @draft_count = draft_count
    @contact_count = contact_count
    total = draft_count + contact_count

    mail(
      to: "olivebase.info@gmail.com",
      # 宛名/本文には投げない
      subject: "特定レコード#{total}件追加のお知らせ"
    )
  end
end
