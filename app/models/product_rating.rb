class ProductRating < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :sweet, :spicy, :bitter, :green, :fruity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  # 一人のユーザーが一つの商品に対して一度しか評価できないようにするバリデーション
  validates :user_id, uniqueness: { scope: :product_id }
end
