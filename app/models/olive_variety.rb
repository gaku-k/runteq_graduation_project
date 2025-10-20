class OliveVariety < ApplicationRecord
  has_many :product_olive_varieties, dependent: :destroy
  has_many :products, through: :product_olive_varieties

  # uniqueness: true nameが一つであることを強制。大文字、小文字が違えば別の値として扱う
  # case_sensitive: false 大文字、小文字の違いを無視して重複をチェックしてくれる
  # allow_blank: true: 値がnilや空文字列の場合を許可する
  validates :name,
            uniqueness: { case_sensitive: false },
            allow_blank: true

  # ProductからOliveVarietyを検索するだけならOliveVariety側でransackable_associationsを定義する必要はない
  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]
  end
end
