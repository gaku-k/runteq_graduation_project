class ProductDraft < ApplicationRecord
  # product_idは編集対象のProductのidが入る。
  # 新規作成では対応するProductレコードは存在しないのでnilを許す必要がある
  belongs_to :product, optional: true
  belongs_to :user

  # 変更リクエストの状態を管理
  enum states: { pending: 0, approved: 1, rejected: 2 }
  # ドラフト(下書き)が「新規作成」の申請なのか「編集」の申請なのかを区別するためのカラム
  enum request_type: { create_new: 0, update_existing: 1, delete_request: 2 }
end
