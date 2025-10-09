class Product < ApplicationRecord
  has_many :product_olive_varieties, dependent: :destroy
  has_many :olive_varieties, through: :product_olive_varieties
  has_many :posts
  has_many_attached :images

  # 直訳:オリーブ品種に対してネストされた属性を許可する。
  # Productの新規作成や更新時にProductのインスタンスを操作する際、関連づけられた:olive_varieties の属性も同時に受け付けて保存する機能
  # allow_destroy: falseはネストされたフォームを通じて削除要求が行われることを拒否する。ユーザーはOliveVariety レコードの削除ができない前提
  accepts_nested_attributes_for :olive_varieties, allow_destroy: false
end
