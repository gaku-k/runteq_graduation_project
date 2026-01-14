module WebpAttachable
  # include: モジュールの機能を自分自身（WebpAttachable）に取り込む。
  # extend: ActiveSupport::Concernが持っている機能を使って、WebpAttachableを「Concern」という特別な存在にアップグレードする。
  extend ActiveSupport::Concern

  # Concernをextendすることで各クラスを主語にしたクラスメソッド(やインスタンスメソッド)を再利用できる.
  # self(主語)は定義地点で固定される。のでこれは誤解 → includeしたクラスならselfの部分を各クラスが補填する
  included do
    # include先のクラスモデルに後付けされる処理
    # updateの場合、ループ中のattachで内部的にupdate暴発し無限ループするため、コントローラーで明示的に呼ぶ
    after_create_commit :convert_images_to_webp!
  end

  # アップロード画像を破壊的にwebp化
  def convert_images_to_webp!
    # ループ元を固定させて、繰り返し処理の対象を限定(attachなどでループ中に増える)
    original_attachments = attachments.to_a

    original_attachments.each do |attachment|
      # 中間テーブルを介してblobsテーブルのカラムにアクセス。すでにwebpなら何もしない
      next if attachment.blob.content_type == "image/webp"

      # 一時ファイルとしてローカルにダウンロード
      attachment.open do |file|
        # file.path=画像ファイルの実体パス。ImageMagickで操作できるオブジェクトとして扱う
        webp = MiniMagick::Image.new(file.path)
        webp.format "webp"

        # ループ中にパージすることで画像を常にバリデーション制約以下にする
        attachment.purge

        attachable.attach(
          # io/filename/content_type は、attachメソッド専用の引数であり。責務ごとに正しい場所に振り分けいる。
          # io(実体データ)はストレージに保存/content_type, filenameはblobsテーブル
          # webp.format "webp"によって生成されたWebPファイル（実体ファイル）をRubyのFileオブジェクトとして開き、ActiveStorageが読める io として渡している
          io: File.open(webp.path),
          # baseで拡張子を除いたファイル名(ベース名)を返す。old_blob.filename.to_s でファイル名となる
          filename: "#{attachment.blob.filename.base}.webp",
          content_type: "image/webp"
        )
      end
    end
  end

  private

  def attachments
    # 各クラス内でimages.attachments/avatar.attachmentという風に定義され、定義が見つからない場合はこちらが呼ばれる。
    raise NotImplementedError
  end

  def attachable
    # images/avatarに画像をattachする用
    raise NotImplementedError
  end
end
