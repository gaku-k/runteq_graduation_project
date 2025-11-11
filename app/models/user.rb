class User < ApplicationRecord
  # 以下Userモデルが持つ機能(モジュール)
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
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

  before_validation :generate_public_id

  enum :role, { general: 0, admin: 1 }

  has_many :posts, dependent: :destroy
  has_many :product_drafts, dependent: :destroy
  has_many :product_ratings, dependent: :destroy
  # 「特定ユーザーが評価した」商品というアソシエーションを付与。実際にはproductを指定していることをsourceで明記
  has_many :rated_products, through: :product_ratings, source: :product
  has_many :contacts, dependent: :destroy
  has_one_attached :avatar

  validates :name, presence: true, length: { minimum: 2, maximum: 30 }
  validates :public_id, presence: true, uniqueness: true

  # スコープ名recoverableを定義/User.recoverableと書けるようになる
  # -> { ... }：ラムダ色(無名関数)でこの中にスコープの条件を書く。つまりroleがadminでないレコードを取得している
  # 用途は？：パスワードリセット機能で用いて、管理者のアカウントは変更されないように除外する。
  # なぜスコープ？：モデルファイルに一行追加するだけで、Deviseの内部処理（ユーザー検索とリセットトークン生成）からAdminユーザーが完全に除外される。
  scope :recoverable, -> { where.not(role: :admin) }
  # 本来はこのスコープ追加と:recoverableの機能の許可ができていればsuper(デフォルト)で機能するらしいのだが、これがなぜか機能しない
  # 対応としてコントローラーのオーバーライドを適応してadminをブロックする

  private
  def generate_public_id
    # public_idが存在しなければ自動生成する
    self.public_id ||= SecureRandom.hex(6)
  end
end
