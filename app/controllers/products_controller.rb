class ProductsController < ApplicationController
  # before_action :autenticate_uer! メソッド: Deviseが提供する「ログインしていなければログインページにリダイレクトする」
  # except :ただし/除く
  before_action :authenticate_user!, except: [ :index, :show ]

  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
    # @olive_varieties を初期化する
    # チェックボックスの選択肢として利用するnilでない品種のみにフィルタリングする
    @olive_varieties = OliveVariety.where.not(name: nil)
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to product_path(@product), success: "ご協力ありがとうございます！"
    else
      flash.now[:danger] = "商品追加に失敗しました"
      # フォーム再表示時に再度@olive_varieties の初期化をしないと選択肢リストを生成できない
      # elseブロックはnewアクションとは独立しているらしく、再定義しないとビューに渡る時点でnilになるという
      @olive_varieties = OliveVariety.where.not(name: nil)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product = Product.find(params[:id])
    @olive_varieties = OliveVariety.where.not(name: nil)
  end

  def update
    @product = Product.find(params[:id])
    # ==============================================
    # 画像なしで更新した場合に元ある画像をパージしないための処理
    # product_params はパラメーターをフィルタリングためのメソッドであり、特定の@productに紐づいたものではない
    # 送信された生のデータにアクセス。なおハッシュの要素アクセスは[]を使う。これはRubyの配列ではなく、配列のように振る舞うコレクションが返る

    # &.: 左側がnilでない場合、エラーを出さずに右を実行する
    # .reject(&:blank?): 空の要素を取り除く処理/画像なしで空文字を送信してしまうのを防ぐ
    new_images = product_params[:images]&.reject(&:blank?)

    # exceptメソッドは特定のキーを除外した新しいハッシュを作る/既存画像への上書き対策
    update_params = product_params.except(:images)

    if new_images.present?
      total_after_attach = @product.images.size + new_images.size
      excess = total_after_attach - 4

      # excess > 0 であるか/追加文含めて4枚以上であるか
      if excess.positive?
        # 「Productとファイルの関係を表すテーブルの行」を直接操作するもの.「どの画像がいつ紐づいたか」を操作できる
        attachments_to_purge = @product.images.attachments
          .reject { |att| att.created_at.nil? }
          .sort_by(&:created_at)
          .first(excess)

        # .eachメソッドの短縮版。attachments_to_purge(配列)に対してpurgeを繰り返す
        attachments_to_purge.each(&:purge)
      end

      @product.images.attach(new_images)
    end
    # ==============================================

    # 引数は元のストロングパラメーター(product_params)ではなく上述のimagesのキーを除外したパラメーターを渡す
    # has_many_attachedの場合、imagesをnilで更新すると空の配列で更新しようとする(Active Recordのデフォルト動作)
    if @product.update(update_params)
      redirect_to product_path(@product), success: "ご協力ありがとうございます！"
    else
      flash.now[:danger] = "送信に失敗しました"
      @olive_varieties = OliveVariety.where.not(name: nil)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :country_of_origin,
      :volume,
      :reference_price,
      :sweet_rating,
      :spicy_rating,
      :bitter_rating,
      :green_rating,
      :fruity_rating,
      images: [],
      # 既存オリーブ品種の選択。配列によるデータ(id)の受け取りを許可し、既存データを再利用
      olive_variety_ids: [],
      # 別テーブルの新しい品種名を許可する
      olive_varieties_attributes: [ :name ]
      # ただしこれだけでは既存品種の再入力で同じ名前の別idのデータが送信できてしまう
    )
  end
end
