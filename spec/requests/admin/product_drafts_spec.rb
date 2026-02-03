require 'rails_helper'

RSpec.describe "Admin::ProductDrafts", type: :request do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin, scope: :user
  end

  describe "PATCH /admin/product_drafts/:id/approve" do
    # 承認では現状request_typeの差異は処理に影響しない
    context "create_requestの場合" do
      # ! をつけることで各itの開始前での実行となる.※共有はされない
      # factoriesでの association :product, :draft_status により、Productも自動生成される
      let!(:product_draft) { create(:product_draft) }

      it "承認でProductが公開され、Draftが承認済みになる" do
        patch approve_admin_product_draft_path(product_draft)
        # 状態確認
        # reloadはDBに再度問い合わせている.同一controller内での状態確認のテストではつけるのが作法らしい
        expect(product_draft.reload.status).to eq "approved"
        expect(product_draft.product.reload.status).to eq "published"
        expect(response).to redirect_to(admin_product_drafts_path)
      end
    end
  end

  describe "PATCH /admin/product_drafts/:id/reject" do
    context "create_requestの場合" do
      let!(:product_draft) { create(:product_draft) }

      it "Productが削除され、Draftのstatusがrejectedになる" do
        # expect { } →「処理・副作用」を検証する
        expect{
          patch reject_admin_product_draft_path(product_draft)
        }.to change(Product, :count).by(-1)

        # expect( ) → すでに評価された「値・状態」を検証する
        expect(product_draft.reload.status).to eq "rejected"
      end
    end

    context "update_requestの場合" do
      let!(:product) { create(:product, name: "元の名前", status: :published) }
      # createする際に、明示的にproductを引数として渡すことで、assoriationで生成されるproductは無視され1:1の関係になる
      let!(:product_draft) do 
        # traitによる上書き
        create(:product_draft, :update_request,
          product_id: product.id,
          name: "変更したい名前",
          # original_attributes がないとロールバック処理が走らない
          original_attributes: { name: "元の名前", status: "published" }
        )
      end

      it "Productがupdate前に戻り、Draftのstatusがrejectedになる" do
        # 申請によってProductが一時的に'draft'かつ'変更後の名前'になっている状態をシミュレート
        product.update!(name: "変更したい名前", status: :draft)

        patch reject_admin_product_draft_path(product_draft)

        expect(product_draft.reload.status).to eq "rejected"
        expect(product.reload.name).to eq "元の名前"
        expect(product.status).to eq "published"
      end
    end
  end
end
