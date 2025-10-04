class ProductOliveVariety < ApplicationRecord
  belongs_to :product
  belongs_to :olive_variety
end
