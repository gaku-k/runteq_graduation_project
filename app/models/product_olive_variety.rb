class ProductOliveVariety < ApplicationRecord
  # createした場合、下書きを介して値を反映させる都合上product_idはまだ存在しない
  belongs_to :product, optional: true # Productに紐づかない場合は必須
  belongs_to :olive_variety
  # 管理者を直接登録した場合、下書きを解さない都合上product_draft_idがnilになる
  belongs_to :product_draft, optional: true # ProductDraftに紐づかない場合は必須
end
