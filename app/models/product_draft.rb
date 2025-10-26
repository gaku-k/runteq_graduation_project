class ProductDraft < ApplicationRecord
  # product_idは編集対象のProductのidが入る。
  # 新規作成では対応するProductレコードは存在しないのでnilを許す必要がある
  belongs_to :product, optional: true
  belongs_to :user
  has_many_attached :images
  has_many :product_olive_varieties, dependent: :destroy
  has_many :olive_varieties, through: :product_olive_varieties
  accepts_nested_attributes_for :olive_varieties, allow_destroy: false, reject_if: :all_blank

  # 変更リクエストの状態を管理
  enum :status, { pending: 0, approved: 1, rejected: 2 }
  # ドラフト(下書き)が「新規作成」の申請なのか「編集」の申請なのかを区別するためのカラム
  enum :request_type, { create_request: 0, update_request: 1, delete_request: 2 }
end
