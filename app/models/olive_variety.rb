class OliveVariety < ApplicationRecord
  has_many :product_olive_varieties, dependent: :destroy
  has_many :products, through: :product_olive_varieties
end
