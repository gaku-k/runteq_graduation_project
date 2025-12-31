class Post < ApplicationRecord
  has_many_attached :images
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :like_posts, dependent: :destroy

  belongs_to :user
  belongs_to :product, optional: true

  validates :product_name, length: { maximum: 100 }, allow_nil: true
  validates :body, length: { maximum: 280 }
  validate :images_count_within_limit
  validate :body_or_images_required

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

  def body_or_images_required
    if body.blank? && !images.attached?
      errors.add(:body, "または画像をアップロードしてください")
      errors.add(:images, "または画像をアップロードしてください")
    end
  end
end
