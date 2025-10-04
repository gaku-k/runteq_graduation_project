class Post < ApplicationRecord
  has_many_attached :images

  validates :product_name, presence: true, length: { maximum: 100 }

  validates :aroma_rating, :taste_rating, :price_rating,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  validates :body, length: { maximum: 1000 }

  validate :images_count_within_limit

  private

  def images_count_within_limit
    if images.attached? && images.count > 4
      errors.add(:images, "は4枚まで添付できます")
      # newページの@post.errorsに格納され、表示される
    end
  end
end
