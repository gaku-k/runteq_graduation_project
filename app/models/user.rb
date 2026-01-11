class User < ApplicationRecord
  # 以下Userモデルが持つ機能(モジュール)
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

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
  # 用途 :外部サービス連携認証（Google, Twitterなど)/googleログイン実装で使用した

  before_validation :generate_public_id

  enum :role, { general: 0, admin: 1 }

  has_many :posts, dependent: :destroy
  has_many :product_drafts, dependent: :destroy
  has_many :product_ratings, dependent: :destroy
  # 「特定ユーザーが評価した」商品というアソシエーションを付与。実際にはproductを指定していることをsourceで明記
  has_many :rated_products, through: :product_ratings, source: :product
  has_many :contacts, dependent: :destroy
  has_one_attached :avatar
  has_many :comments, dependent: :destroy
  has_many :like_posts, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 30 }
  validates :public_id, presence: true, uniqueness: true

  # スコープ名recoverableを定義/User.recoverableと書けるようになる
  # -> { ... }：ラムダ色(無名関数)でこの中にスコープの条件を書く。つまりroleがadminでないレコードを取得している
  # 用途は？：パスワードリセット機能で用いて、管理者のアカウントは変更されないように除外する。
  # なぜスコープ？：モデルファイルに一行追加するだけで、Deviseの内部処理（ユーザー検索とリセットトークン生成）からAdminユーザーが完全に除外される。
  scope :recoverable, -> { where.not(role: :admin) }
  # 本来はこのスコープ追加と:recoverableの機能の許可ができていればsuper(デフォルト)で機能するらしいのだが、これがなぜか機能しない
  # 対応としてコントローラーのオーバーライドを適応してadminをブロックする

  # RailsはURLを生成する時にpublic_idを使うようになる/ルーティングのparam: と連動しているらしい
  def to_param
    # to_paramメソッドを定義しない場合、Railsはデフォルトでid.to_s（IDの文字列）を使う
    # public_idを返すように定義することで、user_path(post.user)としたときに、URLのパス部分にpost.user.public_idの値が埋めこまれる
    public_id
  end

  # ビューモデルで'currentユーザーが'その投稿をいいねしているかを判定する
  def liked_post?(post)
    like_posts.exists?(post_id: post.id)
  end

  # Googleから受け取った情報を元にユーザーを探す、または作成するメソッド/「どのサービス（provider）の」「どのID（uid）か」
  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    # 過去に同じSNSでログインしていればuserを返して終了
    return user if user

    # SNS未連携、emailはDBに存在する場合、重複を防ぐために情報を更新する
    user = find_by(email: auth.info.email)

    if user
      user.update!(
        provider: auth.provider,
        uid: auth.uid
      )
    else
      user = create!(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        # passwordだけgoogleログイン専用ユーザー用に、Deviseがランダムな文字列を用意している。ユーザーはパスワードを入力しない。
        password: Devise.friendly_token[0, 20],
        name: auth.info.name
      )
    end
    # updateの戻り値はtrue。明示的にuserオブジェクトを返す必要がある
    user
  end

  # 情報分裂を防ぐため、パスワード、email変更ページを利用不可にする
  def google_account?
    provider == "google_oauth2"
  end

  private
  def generate_public_id
    # public_idが存在しなければ自動生成する
    self.public_id ||= SecureRandom.hex(6)
  end
end
