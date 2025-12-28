class Comment < ApplicationRecord
  # ancestry gemを使用するためのもの。"Commentが階層構造のidを格納したカラム(ancestry)を持っている"と理解
  has_ancestry

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true,
                   length: { maximum: 280 }
end
