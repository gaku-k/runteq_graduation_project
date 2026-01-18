# namespaceはグループ分けするためのラベル。ファイル名、テーブル名、カラム名とも関連はない
namespace :records do
  desc "未承認の下書きと新規お問い合わせをチェックして管理者に通知する"
  # check_newはタスクの名前。実行の際はnamespaceを借りて rake records:check_new
  # :environment：このタスクを動かす前に、Railsアプリの環境（設定やモデルなど）を読み込んでください」という指示。DB操作ができるようになる
  task check_new: :environment do
    # 新規商品追加申請を確認
    draft_count = ProductDraft.where(status: "pending").count
    # 新規お問い合わせを確認
    contact_count = Contact.where(created_at: 1.day.ago..).count

    if draft_count > 0 || contact_count > 0
      # mailers/以下、AdminMailer クラスのnotification_email(draft_count, contact_count)を呼ぶ
      # mailer ディレクトリは「メール送信という責務をまとめるための場所」/上記の引数をインスタンスとして渡す”メール専用のコントローラーとも言える”
      AdminMailer.notification_email(draft_count, contact_count).deliver_now
      puts "通知メールを送信しました。(商品申請: #{draft_count}, お問い合わせ: #{contact_count})"
    else
      puts "新規レコードがないため、メールは送信しませんでした。"
    end
  end
end
