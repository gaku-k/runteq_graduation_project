class Post < ApplicationRecord
  has_many_attached :images
  belongs_to :user
  belongs_to :product, optional: true

  validates :product_name, presence: true, length: { maximum: 100 }
  validates :aroma_rating, :taste_rating, :price_rating,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :body, length: { maximum: 1000 }
  validate :images_count_within_limit

  # Ransack経由で検索やソートに使っていいカラムを指定している
  def self.ransackable_attributes(auth_object = nil)
    [ "product_name", "body", "created_at", "updated_at" ]
  end

  # Postモデルのアソシエーションを、Ransackで検索・ソートして良い関連として指定する必要がある
  def self.ransackable_associations(auth_object = nil)
    # もしユーザー名などで検索したければ、Userモデルでカラムを指定、許可する必要がある
    [ "user", "images_attachments", "images_blobs" ]
  end

  private

  def images_count_within_limit
    if images.attached? && images.count > 4
      errors.add(:images, "は4枚まで添付できます")
      # newページの@post.errorsに格納され、表示される
    end
  end
end
