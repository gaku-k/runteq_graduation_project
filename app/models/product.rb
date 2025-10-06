class Product < ApplicationRecord
  has_many :product_olive_varieties, dependent: :destroy
  has_many :olive_varieties, through: :product_olive_varieties
  has_many :posts
  has_many_attached :images
end
