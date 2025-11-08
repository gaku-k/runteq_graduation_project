class ProductRating < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # 下のバリデーションで用いる仮想属性を定義する
  attr_accessor :product_page_rating

  # Products/showページから入力する場合のバリデーション
  validates :sweet, :spicy, :bitter, :green, :fruity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 },
            # trueならバリデーションを適応する。
            # フォームのhiddenフィールドにproduct_page_ratingという要素に文字列'false'以外(メソッド参照)の値をセットして送ればバリデーション発動
            # ストロングパラメーターにも許可が必要
            if: :product_page_rating_present?

  # Posts/newページから入力する場合のバリデーション
  validates :aroma, :taste, :price,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 },
            # product_page_ratingが確実にnilまたは'false'である必要がある
            # newフォームに手を加えなくてもメソッドはfalseを返すが、安全に意図を明確にするにはvalue: 'false'をhiddenフィールドに含めるのが推奨される
            unless: :product_page_rating_present?

  # 一人のユーザーが一つの商品に対して一度しか評価できないようにするバリデーション
  validates :user_id, uniqueness: { scope: :product_id }

  private

  def product_page_rating_present?
    # バリデーション対象がproduct_page_ratingという要素がnilでないか/フォームから何らかの値が送信されて、この属性にセットされているかどうかを確認
    # かつ(&&)、この値が文字列として(通常真偽値は非文字列)の"false"と等しくないか。両方満たせばtrue
    self.product_page_rating.present? && self.product_page_rating != "false"
  end
end
