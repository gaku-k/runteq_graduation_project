class Product < ApplicationRecord
  has_many :product_olive_varieties, dependent: :destroy
  has_many :olive_varieties, through: :product_olive_varieties
  has_many :posts
  has_many_attached :images

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

  private

  def images_count_within_limit
    if images.attached? && images.count > 4
      errors.add(:images, "は4枚まで添付できます")
    end
  end
end
