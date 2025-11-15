class ProductsController < ApplicationController
  # create/updateで即時反映させるカラムを定義
  # 大文字で始まる変数 → 定数: 再代入で警告/ .fleeze → 配列を凍結し書き換え不可にする
  IMMEDIATE_UPDATE_COLUMNS = %w[ name ].freeze
  # 1ページあたりの件数
  BOOK_COUNT = 24

  # before_action :autenticate_uer! メソッド: Deviseが提供する「ログインしていなければログインページにリダイレクトする」
  # except :ただし/除く
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :admin_only, only: [ :destroy ]

  def index
    # @products = Product.published
    @q = Product.ransack(params[:q])
    @products = @q.result(distinct: true)
                  .order(created_at: :desc)
                  # ページネーション追加
                  .page(params[:page])
                  # 1ページあたりの件数
                  .per(BOOK_COUNT)
  end

  def show
    @product = Product.find(params[:id])
    # find_or_initialize_by: 指定した条件に合うオブジェクトが存在すれば取得、なければ新しいオブジェクトをbuildする。
    # find_or_create_byと違い保存はしない
    @product_rating = @product.product_ratings.find_or_initialize_by(user: current_user)
    # メソッドはモデルに記載。レーダーチャート用の平均値, 評価件数をビューに渡す
  end

  def new
    @product = Product.new
    # @olive_varieties を初期化する
    # チェックボックスの選択肢として利用するnilでない品種のみにフィルタリングする
    @olive_varieties = OliveVariety.where.not(name: nil)
  end

  def create
    if current_user.admin?
      @product = Product.new(product_params)
      # adminなら即公開。saveを実行する前にstatueを設定し、saveメソッドで保存する
      @product.status = :published

      if @product.save
        redirect_to products_path, success: "商品情報が即座に更新されました"
      else
        flash.now[:danger] = "商品追加に失敗しました"
        # フォーム再表示時に再度@olive_varieties の初期化をしないと選択肢リストを生成できない
        # elseブロックはnewアクションとは独立しているらしく、再定義しないとビューに渡る時点でnilになるという
        @olive_varieties = OliveVariety.where.not(name: nil)
        render :new, status: :unprocessable_entity
      end

    else
      # .mergeメソッドは既存のハッシュに新しいキーと値を追加(または上書き)する
      draft_params = product_params.merge(
        # Q 相手方のカラムに依存するならuser_id:では？ → どちらも可。associationを通じてRailsがuser_idを設定してくれる
        user: current_user,
        status: :pending,
        request_type: :create_request
        # product_idは編集対象のProductのidが入る。新規作成では対応するProductレコードは存在しない
      )
      @draft = ProductDraft.new(draft_params)

      # begin~(例外が起こるかもしれない処理)~rescue~(例外が発生した時の処理)~end
      begin
        # transaction:モデルに対する複数のデータベース操作を一つのまとまりとし、全部成功か全部失敗かにする
        # ActiveRecord::Baseはすべてのモデルの親(包括しているわけではない)
        ActiveRecord::Base.transaction do
          @draft.save!

          # 即時反映を希望するカラムをProductにも反映したい
          immediate_params = extract_immediate_params(product_params)
          @product = Product.new(immediate_params)
          @product.status = :draft
          # ===============================
          # OliveVarietyのIDを取得する処理/accepts_nested_attributes_forによる品種テーブルへのデータ蓄積を防ぐ準備
          # product_params から olive_varieties_attributes のハッシュを取り出す
          new_variety_names = product_params.dig(:olive_varieties_attributes)
                              &.to_h # ActionController::Parameters オブジェクトを、普通のRubyハッシュに変換
                              &.reject { |_, attrs| attrs[:id].present? } # idを持っている（＝既存レコードの）要素を除外
                              &.map { |_, attrs| attrs[:name] } # 名前だけの配列にする
                              &.compact # 空欄除外
                              &.uniq || [] # 重複除外
          @product.save! # ここで新規オリーブ品種が保存されIDが振られる

          new_variety_ids = OliveVariety.where(name: new_variety_names).pluck(:id) # 保存されたidを収集
          # ===============================
          # ProductDraftにproduct_idを関連付け/オリーブの品種idを格納,申請拒否でこれを使って品種テーブルから品種レコードを削除する狙い
          @draft.update!(product: @product, new_olive_variety_ids: new_variety_ids)
        end
          redirect_to products_path, notice: "商品追加リクエストを管理者へ送信しました"

      rescue ActiveRecord::RecordInvalid => e
        flash.now[:danger] = "商品追加に失敗しました"
        @olive_varieties = OliveVariety.where.not(name: nil)
        # transaction 内で初期化できなかった場合のために @product を作る
        @product ||= Product.new(product_params)
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    @product = Product.find(params[:id])
    @olive_varieties = OliveVariety.where.not(name: nil)
  end

  def update
    @product = Product.find(params[:id])

    # 定義元はreturnで値を返しているが、後続の処理で使いたい場合多重代入をする必要がある
    update_params, new_images = prepare_image_update_params(@product, product_params)

    if current_user.admin?
      perform_image_update(@product, new_images)

      # 引数は元のストロングパラメーター(product_params)ではなく上述のimagesのキーを除外したパラメーターを渡す
      # has_many_attachedの場合、imagesをnilで更新すると空の配列で更新しようとする(Active Recordのデフォルト動作)
      if @product.update(update_params)
        redirect_to products_path, success: "商品情報が即座に更新されました"
      else
        flash.now[:danger] = "商品追加に失敗しました"
        @olive_varieties = OliveVariety.where.not(name: nil)
        render :edit, status: :unprocessable_entity
      end

    else
      # Productモデルで has_many :product_drafts と定義しているので、Railsが自動的に関連メソッド(product_drafts)を生成する
      # buildメソッド:関連モデル(ProductDraft)の新インスタンスを生成する
      @draft = @product.product_drafts.find_by(status: :pending) || @product.product_drafts.build
      # ========================================
      # ロールバック処理のため、update前の状態を保存する。とはいえ即時反映されるカラムだけを対象にすればよく、それ以外はrejectアクションで除外できる
      if @draft.new_record? # .new_record? "dbに保存されていない"、"新規のレコード"ならtrue
        original_attrs =  @product.slice(*IMMEDIATE_UPDATE_COLUMNS, :status)
        @draft.original_attributes = original_attrs

        # 画像はテーブルカラムとして保存していない。「Productに紐づいていたときのBlobのID」という参照情報を元に復元する必要がある
        original_blobs = @product.images.attachments.map do |att|
          { blob_id: att.blob_id, filename: att.filename.to_s }
        end
        @draft.original_image_blobs = original_blobs
      end
      # ========================================

      # :image　キーを含まないupdate_paramsで画像なし送信からの初期化を防ぐ
      draft_params = update_params.merge(
        user: current_user,
        status: :pending,
        request_type: :update_request
      )

      begin
        ActiveRecord::Base.transaction do
          @draft.update!(draft_params)

          # 画像の玉突き処理を実行し、ProductDraftに複製、添付する
          perform_draft_image_update(@draft, @product, new_images)
          immediate_params = extract_immediate_params(product_params)

          # status: :draftをマージしなければpublished(update故の初期値)となる
          product_updates = immediate_params.merge(status: :draft)
          # ================================
          # accepts_nested_attributes_forによって新規作成されたオリーブ品種のIDを抽出。申請却下でこれをDBから削除する狙い
          # @productは即時反映カラム(オリーブ品種はない)しか持っていない
          # product_params から olive_varieties_attributes のハッシュを取り出す
          new_variety_names = product_params.dig(:olive_varieties_attributes)
                            &.to_h
                            &.reject { |_, attrs| attrs[:id].present? }
                            &.map { |_, attrs| attrs[:name] }
                            &.compact
                            &.uniq || []

          @product.update!(product_updates) # ここで新規オリーブ品種が保存されIDが振られる
          # DBから新規IDを取得
          new_variety_ids = OliveVariety.where(name: new_variety_names).pluck(:id)

          # 既存の保存済みIDを取得 (nil対策とArray変換)
          existing_ids = @draft.new_olive_variety_ids.to_a
          merged_ids = (existing_ids + new_variety_ids).uniq
          # ===============================
          @draft.update!(new_olive_variety_ids: merged_ids)
        end
          redirect_to products_path, notice: "商品更新リクエストを管理者へ送信しました"

      rescue ActiveRecord::RecordInvalid => e
        flash.now[:danger] = "商品追加に失敗しました"
        @olive_varieties = OliveVariety.where.not(name: nil)
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @product = Product.find(params[:id])
    if @product.destroy
      redirect_to products_path, notice: "商品を削除しました"
    else
      render show, alert: "商品削除に失敗しました"
    end
  end

  private

  def extract_immediate_params(params)
    # *（スプラット演算子）は「配列を展開して個別の引数として渡す」
    # *がないとparamsのキーだけが抽出される
    params.slice(*IMMEDIATE_UPDATE_COLUMNS)
  end

  # 呼び出し側はインスタンス変数(@product)を使い、メソッド定義側ではローカル変数(product)となる
  def prepare_image_update_params(product, params)
    # product_params はパラメーターをフィルタリングためのメソッドであり、特定の@productに紐づいたものではない
    # 送信された生のデータにアクセス。なおハッシュの要素アクセスは[]を使う。これはRubyの配列ではなく、配列のように振る舞うコレクションが返る

    # &.: 左側がnilでない場合、エラーを出さずに右を実行する
    # .reject(&:blank?): 空の要素を取り除く処理/画像なしで空文字を送信してしまうのを防ぐ
    new_images = product_params[:images]&.reject(&:blank?)
    # exceptメソッドは特定のキーを除外した新しいハッシュを作る/既存画像への上書き対策
    update_params = product_params.except(:images)
    # return はメソッドの戻り値を明示的に指定して終了、配列として返す。なくてもいいが、わかりやすい書き方
    return update_params, new_images
  end

  # admin用:画像なしで更新した場合に元ある画像をパージしないための処理
  def perform_image_update(product, new_images)
    return unless new_images.present? || params[:product].key?(:images)

    existing_attachments = product.images.attachments.to_a
    # 送信された新しい画像と既存画像を結合
    combined_images = existing_attachments + new_images
    # 最終的にProductDraftに添付したい画像（最新の4枚）
    images_to_attach = combined_images.last(4)

    # 関連を一度削除することで、最終的に紐づけたい状態を確実に反映させる
    draft.images.attachments.destroy_all

    images_to_attach.each do |item|
      # object.is_a?() オブジェクトの型を調べるメソッド
      if item.is_a?(ActiveStorage::Attachment)
        # 既存のProductの画像（Attachment）の場合
        # Blob（実際のファイルデータ）をコピーせずに、そのBlobを参照する新しいAttachmentを作成する
        ActiveStorage::Attachment.create!(
          name: "images",
          record: draft,
          blob: item.blob # 既存のBlobを再利用
        )
      else
        # 新規にアップロードされたファイルの場合 (ActionDispatch::Http::UploadedFile)
        # これは新しいBlobとして保存される
        draft.images.attach(item)
      end
    end
  end

  # 非admin用:画像なしで更新した場合に元ある画像をパージしないための処理
  def perform_draft_image_update(draft, product, new_images)
    return unless new_images.present? || params[:product].key?(:images)

    # 既存の添付ファイルをrubyの配列に変換して取得
    existing_attachments = product.images.attachments.to_a
    combined_images = existing_attachments + new_images
    images_to_attach = combined_images.last(4)
    # 関連を一度削除することで、最終的に紐づけたい状態を確実に反映させる
    draft.images.attachments.destroy_all

    images_to_attach.each do |item|
      # obuject.is_a?() オブジェクトの型を調べるメソッド
      if item.is_a?(ActiveStorage::Attachment)
        # blobは実際のファイルデータ
        # ProductからProductDraftへ画像をコピーしている
        blob = item.blob
        draft.images.attach(
          io: StringIO.new(blob.download),
          filename: blob.filename,
          content_type: blob.content_type
        )
      else
        draft.images.attach(item)
      end
    end
  end

  def admin_only
    unless current_user&.admin?
      redirect_to root_path, alert: "権限がありません。"
    end
  end

  def product_params
    params.require(:product).permit(
      :name,
      :country_of_origin,
      :volume,
      :reference_price,
      images: [],
      # 既存オリーブ品種の選択。配列によるデータ(id)の受け取りを許可し、既存データを再利用
      olive_variety_ids: [],
      # 別テーブルの新しい品種名を許可する
      olive_varieties_attributes: [ :name ]
      # ただしこれだけでは既存品種の再入力で同じ名前の別idのデータが送信できてしまう
    )
  end
end
