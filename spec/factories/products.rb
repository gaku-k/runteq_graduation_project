FactoryBot.define do
  factory :product do
    name { "テスト商品" }
    status { :published }

    trait :draft_status do
      status { :draft }
    end
  end
end
