require 'rails_helper'

# request specでは画面は一切関知せずHTTPリクエストとして直接データを送る
RSpec.describe "Posts", type: :request do
  # let(:user): user というメソッドを定義
  # テスト間で共有されず各it間で user と呼べば生成できる.beforeは毎回作られる
  let(:user) { create(:user) }

  describe "POST /posts" do

      it "GET /posts/new は 200 OK を返す" do
        sign_in user, scope: :user
        get new_post_path
        expect(response).to have_http_status(:ok)
      end

    context "ログインしている場合" do
      before do
        sign_in user, scope: :user
      end

      it "バリデーションが正しい場合、Postが作成される" do
        expect {
          post posts_path, params: {
            post: {
              body: "本文" 
            } 
          }
        }.to change(Post, :count).by(1)   # DBの件数が増えたことを確認

        expect(response).to redirect_to(posts_path)  # リダイレクト先を確認
      end
  
      it "バリデーションが不正な場合、Postが作成されない" do
        expect {
          post posts_path, params: {
            post: {
              body: ""
            }
          }
        }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "ログインしていない場合" do
      it "Postが作成されず、ログイン画面にリダイレクトされる" do
        expect {
          post posts_path, params: {
            post: {
              body: "本文"
            }
          }
        }.not_to change(Post, :count)

        expect(response).to redirect_to(new_user_session_path)  # Devise のログインページ
      end
    end

  end
end
