class Admin::ProductDraftsController < ApplicationController
  # ProductDraftに特化したカラム(Productに存在しないカラム)
  EXCLUDED_DRAFT_COLUMNS = %w[
    id product_id user_id status request_type created_at updated_at original_image_blobs original_attributes new_olive_variety_ids
  ].freeze

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

        # 承認後に Product の画像を WebP 化する(申請時はできていない)
        @draft.product.convert_images_to_webp!
      end
      # トランザクション成功後、ProductDraftに紐づいていた画像を削除
      @draft.images.purge_later if @draft.images.attached?
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
          # 3. 今回のdraftで追加された品種をOliveVarietiesテーブルから削除
          destroy_new_olive_varieties

          @draft.update!(status: :rejected)

        elsif @draft.request_type == "create_request"
          # 今回のdraftで追加された品種をOliveVarietiesテーブルから削除
          destroy_new_olive_varieties
          # 削除対象をローカル変数に一時保存
          product_to_destroy = @draft.product
          # 外部キーを削除することで、参照元を削除可能にする
          @draft.update!(status: :rejected, product_id: nil)

          # product_idをnilにしているので、@draft.productではオブジェクトを見つけられない
          product_to_destroy.images.purge_later if product_to_destroy.images.attached?
          product_to_destroy.destroy!
          # draftに紐づいた画像を削除
          @draft.images.purge_later if @draft.images.attached?
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
    product_attributes = @draft.attributes.except(*EXCLUDED_DRAFT_COLUMNS)

    @draft.product.update!(product_attributes)

    @draft.product.product_olive_varieties.destroy_all
    @draft.olive_varieties.each do |variety|
      @draft.product.olive_varieties << variety
    end

    if @draft.images.attached?
      @draft.product.images.attachments.destroy_all

      @draft.images.attachments.each do |attachment|
        blob = attachment.blob

        ActiveStorage::Attachment.create!(
        name: "images", # has_many_attached :images の関連付け名
        record: @draft.product, # 紐づけるモデルインスタンス
        blob: blob # ProductDraftが参照していたActiveStorage::Blobオブジェクトを再利用
        )
      end
    end
  end

  # Productを元の属性とステータスにロールバック
  def rollback_product_attributes
    # imagesはカラムではないので{"images" => "値2"}とは渡せないから省く。
    original_attrs = @draft.original_attributes.except("images")
    # original_attributesカラム実装前の古いProductDraftレコード(があると仮定)には当カラムが存在しないのでスキップする必要がある
    # 予期せぬ状態変化によってnilになり得るオブジェクトには、このように存在チェックを行うことで堅牢性を保証するとのこと
    return unless original_attrs.present? # return unless 条件：条件が真の時処理を'続ける'

    # JSONデータをハッシュに変換して更新。キーをシンボル化する
    # original_attributesカラムのデータ型が jsonb であり、キーは文字列(string)として扱われる。update!メソッドは引数として渡されるハッシュのキーがシンボルであることを期待する
    @draft.product.update!(original_attrs.symbolize_keys)
  end

  # Productの画像を元の状態に復元
  def rollback_product_images
    return unless @draft.original_image_blobs.present?

    # A. ロールバック後に「残すべき」Blob IDのリスト/to_iはstringをintegerにする
    keep_blob_ids = @draft.original_image_blobs.map { |b| b["blob_id"].to_i }

    # B. 現在Productに紐づいている画像の中で「却下対象」のものを特定
    unwanted_attachments = @draft.product.images.attachments.reject do |att|
      keep_blob_ids.include?(att.blob_id)
    end

    # C. 却下対象の画像をストレージから削除
    unwanted_attachments.each(&:purge_later)

    # D. 元の画像を再アタッチする/original_image_blobsの中身例:[{ "blob_id": 12, "filename": "a.jpg" },{ "blob_id": 15, "filename": "b.png" }]
    @draft.original_image_blobs.each do |blob_info|
      # jsonb に保存されていた blob_id を使って実際の blob がまだ存在するか確認。削除済みなら nil
      blob = ActiveStorage::Blob.find_by(id: blob_info["blob_id"])
      # 存在し(purgeしていない)、Product にこの blob が紐づいていない(二重attachでない)か確認
      if blob && !@draft.product.images.blobs.include?(blob)
        @draft.product.images.attach(blob)
      end
    end
  end

  def destroy_new_olive_varieties
    # draftに挙がって来る時点で、Productコントローラーにより新規品種(既存品種除く)だけのidの配列になっている
    variety_ids = @draft.new_olive_variety_ids
    return unless variety_ids.present?

    # new_olive_variety_idsには新規作成されたIDのみが入っているため、無条件で削除しても安全
    OliveVariety.where(id: variety_ids).destroy_all
    @draft.update_column(:new_olive_variety_ids, [])
  end

  def authorize_admin
    redirect_to root_path, alert: "管理者権限が必要です。" unless current_user.admin?
  end

  def set_draft
    @draft = ProductDraft.find(params[:id])
  end
end
