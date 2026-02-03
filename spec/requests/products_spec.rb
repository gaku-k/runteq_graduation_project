require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  # 非公開(保留中)か、公開済みか。
  #enum :status, { draft: 0, published: 1 }

  describe "POST /products" do
    context "一般ユーザーでログインしている場合" do
      before do
        sign_in user, scope: :user
      end

      it "バリデーションが正しい場合、新規Productが管理者ユーザーへ申請される" do
        expect {
          post products_path, params: {
            product: {
              name: "オリーブオイルA"
            }
          }
        }.to change(Product, :count).by(1)
         .and change(ProductDraft, :count).by(1)

        # ステータス検証
        product = Product.last
        expect(product.status).to eq "draft"
        draft = ProductDraft.last
        expect(draft.status).to eq "pending"
        expect(response).to redirect_to products_path
      end

      it "バリデーションが不正な場合、新規Productが管理者ユーザーへ申請されない" do
        expect {
          post products_path, params: {
            product: {
              name: ""
            }
          }
        }.to change(Product, :count).by(0)
         .and change(ProductDraft, :count).by(0)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "管理医者ユーザーでログインしている場合" do
      before do
        sign_in admin_user, scope: :user
      end

      it "バリデーションが正しい場合、新規Productが作成される" do
        expect {
          post products_path, params: {
            product: {
              name: "オリーブオイルA"
            }
          }
        }.to change(Product, :count).by(1)
         .and change(ProductDraft, :count).by(0)

        product = Product.last
        expect(product.status).to eq "published"
        expect(response).to redirect_to products_path
      end

      it "バリデーションが不正場合、新規Productが作成されない" do
        expect {
          post products_path, params: {
            product: {
              name: ""
            }
          }
        }. to change(Product, :count).by(0)
         .and change(ProductDraft, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
      end

    end

    context "ログインしていない場合" do

      it "Productが作成されず、ログイン画面にリダイレクトされる" do
        expect {
          post products_path, params: {
            product: {
              name: "オリーブオイルA"
            }
          }
        }.not_to change(Product, :count)

        expect(response).to redirect_to(new_user_session_path)  # Devise のログインページ
      end
    end

  end
end
