class LikePost < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # user_idと、post_idの組み合わせが一意である制約。二重いいねを防止する
  validates :user_id, uniqueness: { scope: :post_id }
end
