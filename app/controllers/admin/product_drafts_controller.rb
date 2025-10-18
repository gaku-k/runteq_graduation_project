class Admin::ProductDraftsController < ApplicationController
  # ユーザーがログインしているかを確認
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :set_draft, only: [ :show, :approve, :reject ]

  def index
    # includesは関連するProductとUserの情報を事前に読み込む
    @drafts = ProductDraft.pending.includes(:product, :user)
  end

  def show
  end

  def approve
    begin
      ActiveRecord::Base.transaction do
        # オリーブ品種、画像などの紐付け処理
        reflect_draft_to_product
        @draft.product.update!(status: :published)
        @draft.update!(status: :approved)
      end
      redirect_to admin_product_drafts_path, notice: "商品申請を承認し、商品を公開しました"

    rescue ActiveRecord::RecordInvalid => e
      # バリデーションエラーなどで失敗した場合
      flash[:danger] = "承認処理に失敗しました: #{e.message}"
      render :show, status: :unprocessable_entity
    rescue StandardError => e
      # その他のエラー（データベースエラーなど）
      flash[:danger] = "承認処理中に予期せぬエラーが発生しました: #{e.message}"
      redirect_to admin_product_drafts_path
    end
  end

  def reject
    if @draft.update!(status: :rejected)
      redirect_to admin_product_drafts_path, alert: "商品申請を却下しました"
    else
      flash[:danger] = "却下処理に失敗しました。"
      render :show, status: :unprocessable_entity
    end
  end

  private

  def reflect_draft_to_product
    # ProductDraftに特化したカラムを除外
    product_attributes = @draft.attributes.except(
      "id", "product_id", "user_id", "status", "request_type", "created_at", "updated_at"
    )

    @draft.product.update!(product_attributes)

    @draft.product.product_olive_varieties.destroy_all
    @draft.olive_varieties.each do |variety|
      @draft.product.olive_varieties << variety
    end

    if @draft.images.attached?
      @draft.product.images.attachments.destroy_all

      @draft.images.attachments.each do |attachment|
        blob = attachment.blob
        @draft.product.images.attach(
          io: StringIO.new(blob.download), # Blobの実体データをダウンロード
          filename: blob.filename,
          content_type: blob.content_type
        )
      end
    end
  end

  def authorize_admin
    redirect_to root_path, alert: "管理者権限が必要です。" unless current_user.admin?
  end

  def set_draft
    @draft = ProductDraft.find(params[:id])
  end
end
