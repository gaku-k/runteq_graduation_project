FactoryBot.define do
  # create(:user)で生成
  factory :user do
    name { "一般ユーザー" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password" }
    role { :general }

    # 同じuserに属性を上書きすることでfactoryが増えすぎない仕組み
    # create(:user, :admin)で呼ばれ、別インスタンスとして2人作ることもできる
    trait :admin do
      name { "管理者ユーザー" }
      role { :admin }
    end
  end
end
