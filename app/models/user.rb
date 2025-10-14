class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # 以下Userモデルが持つ機能(モジュール)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # :database_authenticatable :対応C sessions_controller.rb
  # 用途 :ログイン/ログアウト

  # :registerable :対応C registrations_controller.rb
  # 用途 :サインアップ、アカウント編集、アカウント削除

  # :recoverabl :対応C passwords_controller.rb
  # 用途 :パスワードリセット

  # :rememberable :制御ロジックは主にDevise内部で行われるため、専用のコントローラーは不要
  # 用途 :ログイン情報を記憶する
  # 「次回から自動でログイン」のようなチェックボックスをオンにすると、セッションだけでなく、ブラウザのCookieに永続的な認証トークンを保存する
  # カスタマイズは主に、Cookieの有効期限（devise.rb内）を設定するか、ログインビュー（sessions/new.html.erb）のフォームに「Remember me」のチェックボックスを追加する形

  # :validatable :処理はモデルレベルで行われるため、専用のコントローラーは不要
  # 用途 :メールアドレスとパスワードのフォーマット検証 機能を提供
  # Deviseの組み込みのバリデーション（検証）機能。デフォルトでは、メールアドレスの形式が正しいか、パスワードの長さが適切か（6文字以上128文字以下など）をチェック
  # カスタマイズはdevise.rb：パスワードの最小・最大文字数などのルールを変更する/必要に応じて独自のカスタムバリデーションをモデルファイルに追加する
  # -------------------------------------
  # 以下自動生成されるコントローラーファイルと対応するDeviseモジュール
  # 該当コントローラーが必要になれば、このファイルに追加していく

  # :confirmable :対応C confirmations_controller.rb
  # 用途 :アカウント確認（メールアドレスの有効性確認）

  # :lockable :対応C unlocks_controller.rb
  # 用途 :アカウントロック解除（不正ログイン防止のためのアカウントロック）

  # :omniauthable :対応C omniauth_callbacks_controller.rb
  # 用途 :外部サービス連携認証（Google, Twitterなど)

  # ユーザーが削除されたら、その投稿も削除
  has_many :posts, dependent: :destroy
end
