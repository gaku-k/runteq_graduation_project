FactoryBot.define do
  factory :product_draft do
    # テストでこのサンプルを作るとき、:product factory に :draft_status trait を付けて自動で create する
    # 内部的には　create(:product, :draft_status)
    association :product, :draft_status
    # user_idカラム(null: false)を満たすオブジェクト
    association :user
    name { "申請中の商品名" }
    status { :pending }
    request_type { :create_request }

    trait :update_request do
      request_type { :update_request }
    end
  end
end
