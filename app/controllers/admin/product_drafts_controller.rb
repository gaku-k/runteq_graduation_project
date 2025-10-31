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
    @draft = ProductDraft.find(params[:id])
    begin
      ActiveRecord::Base.transaction do

        if @draft.request_type == "update_request"
          # 1. Productを元の属性とステータスにロールバック
          rollback_product_attributes
          # 2. Productの画像を元の状態に復元
          rollback_product_images

          @draft.update!(status: :rejected)

        elsif @draft.request_type == "create_request"
          # 削除対象をローカル変数に一時保存
          product_to_destroy = @draft.product
          # 外部キーを削除することで、参照元を削除可能にする
          @draft.update!(status: :rejected, product_id: nil)
          # ローカル変数を使ってProductを削除(※product_idをnilにしているので、@draft.productではオブジェクトを見つけられない)
          product_to_destroy.destroy!
        end
      end
      
      # リダイレクトメッセージを分岐
      if @draft.request_type == "create_request"
          alert_message = "新規商品申請を却下し、作成されたProductを完全に削除しました。"
      else
          alert_message = "商品更新申請を却下し、Productを元の状態に復元しました。"
      end

      redirect_to admin_product_drafts_path, alert: alert_message
    
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = "却下処理に失敗しました: #{e.message}"
      render :show, status: :unprocessable_entity
    rescue StandardError => e
      flash[:danger] = "却下処理中に予期せぬエラーが発生しました: #{e.message}"
      redirect_to admin_product_drafts_path
    end
  end

  private

  def reflect_draft_to_product
    # ProductDraftに特化したカラム(Productに存在しないカラム)を除外
    product_attributes = @draft.attributes.except(
      "id", "product_id", "user_id", "status", "request_type", "created_at", "updated_at", "original_image_blobs", "original_attributes"
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

  def rollback_product_attributes
    original_attrs = @draft.original_attributes
    # original_attributesカラム実装前の古いProductDraftレコード(があると仮定)には当カラムが存在しないのでスキップする必要がある
    # 予期せぬ状態変化によってnilになり得るオブジェクトには、このように存在チェックを行うことで堅牢性を保証するとのこと
    return unless original_attrs.present? # return unless 条件：条件が真の時処理を'続ける'

    # JSONデータをハッシュに変換して更新。キーをシンボル化する
    # original_attributesカラムのデータ型が jsonb であり、キーは文字列(string)として扱われる。update!メソッドは引数として渡されるハッシュのキーがシンボルであることを期待する
    @draft.product.update!(original_attrs.symbolize_keys)
  end

  def rollback_product_images
    original_image_blobs = @draft.original_image_blobs
    return unless original_image_blobs.present?

    # 1. Productの現在の画像を全て削除/提出前の元の画像セットを再アタッチする準備
    @draft.product.images.attachments.destroy_all

    # 2. オリジナル情報（Blob ID）を元に、既存の Blob を Product に再添付する
    original_image_blobs.each do |blob_info|
      # ProductsController で保存したロジックから、ハッシュは{ "blob_id" => 10, "filename" => "olive_oil_front.jpg" } のようになる。
      # id: active_storage_blobs テーブルの主キー
      # blob_id: 別のテーブル（active_storage_attachments）で、ActiveStorage::Blob のidを参照するための外部キー
      blob = ActiveStorage::Blob.find_by(id: blob_info["blob_id"])

      # Blobが見つからなかった場合に備えて存在確認
      if blob
        ActiveStorage::Attachment.create!(
          name: 'images', # has_many_attached :images の関連付け名
          record: @draft.product, # 紐づけるモデルインスタンス
          blob: blob # 紐づけるActiveStorage::Blobオブジェクト
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
