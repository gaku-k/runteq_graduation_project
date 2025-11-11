Rails.application.routes.draw do
  # devise_for :users
  # どのCを使うかを明示的に表しており、デフォルトのままだとコマンドで生成したカスタムCを使ってくれない
  devise_for :users, controllers: {
    # 左: Deviseのコントローラーを　右: 自分のアプリ内のコントローターに置き換えている
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords"
    # 必要に応じて以下も追加
    # confirmations: "users/confirmations",
    # omniauth_callbacks: "users/omniauth_callbacks",
    # unlocks: "users/unlocks"
  }

  # トップページを指定
  root "posts#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  resources :posts, only: [ :index, :show, :new, :create, :destroy ]
  resources :products, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    # ネストすることで、どの商品に紐づいた評価かをURL構造で判断しやすくなる
    # またコントローラー側でparams[:product_id]から商品を特定できる
    resources :product_ratings, only: [ :create, :update ]
    # product/showページからその商品に基づいた投稿を行う
    resources :posts, only: [ :new ]
  end

  resource :user, only: [ :show ]
  # /users/:id の:id部分がpublic_idに置き換わる。コントローラーも代わる
  # resources :users, params: :public_id, only: [ :show ]
  resources :contacts, only: [ :new, :create ]

  # namespaxe はURLとコントローラーをグループ化する機能「admin/ で始まるURL → Admin名前空間のコントローラに送る」
  namespace :admin do
    get "contacts/index"
    get "contacts/show"
    resources :contacts, only: [ :index, :show ]
    resources :product_drafts, only: [ :index, :show ] do
      # member: id持ち個別レコードに対して、approve、rejectというアクションを追加
      member do
        # PATCH: レコードの部分更新をリクエストするHTTPメソッド
        # リクエスト送信で、コントローラー内のapprove, rejectアクションが実行される
        patch :approve
        patch :reject
      end
    end
  end

  # 複数の静的ページ
  # :pages というコントローラを前提に、2つのアクションを定義
  controller :pages do
    get :terms
    get :privacy
  end
end
