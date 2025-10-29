class Product < ApplicationRecord
  has_many :product_olive_varieties, dependent: :destroy
  has_many :olive_varieties, through: :product_olive_varieties
  has_many :posts
  has_many_attached :images
  has_many :product_drafts
  has_many :product_ratings, dependent: :destroy
  # 「特定商品の評価者」というアソシエーションを付与。実際にはuserを指定していることをsourceで明記
  has_many :rated_users, through: :product_ratings, source: :user

  # 非公開(保留中)か、公開済みか。
  enum :status, { draft: 0, published: 1 }

  # 直訳:オリーブ品種に対してネストされた属性を許可する。
  # Productの新規作成や更新時にProductのインスタンスを操作する際、関連づけられた:olive_varieties の属性も同時に受け付けて保存する機能
  # allow_destroy: falseはネストされたフォームを通じて削除要求が行われることを拒否する。ユーザーはOliveVariety レコードの削除ができない前提
  # reject_if: :all_blank: ネストされた属性を受け取るとき「空欄は無視する」/空文字が重複し,unique 違反する問題解消のため
  accepts_nested_attributes_for :olive_varieties, allow_destroy: false, reject_if: :all_blank

  validates :name, presence: true, length: { maximum: 100 }
  validates :sweet_rating, :spicy_rating, :bitter_rating, :green_rating, :fruity_rating,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  validates :volume, numericality: { only_integer: true }, allow_nil: true
  # numericality: true は整数・少数どちらも許可する
  validates :reference_price, numericality: true, allow_nil: true

  # postモデルと全く同じもの。共通のバリデーションを定義したモジュールを作成し、各モデルでincludeする手もある
  validate :images_count_within_limit

  def self.ransackable_attributes(auth_object = nil)
    [ "name", "country_of_origin", "volume", "reference_price", "created_at", "updated_at" ]
  end

  # 関連名を通じてRansackは自動的にJOINを組み立てる。中間テーブルを介せずolive_varietiesとかける
  def self.ransackable_associations(auth_object = nil)
    [ "olive_varieties", "images_attachments", "images_blobs" ]
  end

  # レーダーチャートに平均値を渡す。
  def average_ratings
    ratings = product_ratings

    {
      # 評価が一件もないなら0点で返す。データがないなら値0のチャートを表示してレイアウトを崩さない
      # .round(1)で小数点一桁までの値を返す。
      sweet: (ratings.average(:sweet) || 0).round(1),
      spicy: (ratings.average(:spicy) || 0).round(1),
      green: (ratings.average(:green) || 0).round(1),
      fruity: (ratings.average(:fruity) || 0).round(1),
      bitter: (ratings.average(:bitter) || 0).round(1)
    }
  end

  def ratings_count
    product_ratings.count
  end

  private

  def images_count_within_limit
    if images.attached? && images.count > 4
      errors.add(:images, "は4枚まで添付できます")
    end
  end
end
