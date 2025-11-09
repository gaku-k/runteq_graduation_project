class PostsController < ApplicationController
  # 1ページあたりの件数
  BOOK_COUNT = 24
  # before_action :autenticate_uer! メソッド: Deviseが提供する「ログインしていなければログインページにリダイレクトする」
  # except :ただし/除く
  before_action :authenticate_user!, except: [ :index, :show ]
  # @productを特定する共通メソッドを用意（newとcreateで利用）
  before_action :set_product_from_params, only: [ :new, :create ]

  def index
    # @params[:q]に検索フォームから送られたパラメータが入る.
    @q = Post.ransack(params[:q])
    # resultメソッドはparams[:q]がnilなら全件(Post.all)を返す
    # distinct: true 同じレコードが重複して出ないようにするオプション
    @posts = @q.result(distinct: true)
               # 絞り込みした結果に基づくユーザーとアバターを一括で読み込む
               .includes(user: { avatar_attachment: :blob }, product: :product_ratings)
               # .order(created_at: :desc)で新しいものほど上/更新日時ならorder(updated_at: :desc)となる。逆順は(~: :asc)
               .order(created_at: :desc)
               # ページネーション追加
               .page(params[:page])
               # 1ページあたりの件数
               .per(BOOK_COUNT)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    # 空のPostオブジェクトを作成
    @post = current_user.posts.build

    # 「この商品でPostする」からの遷移を想定
    if @product
      @post.product_name = @product.name
      # showページで商品名をリンク化するのでidも保持させる
      @post.product_id = @product.id

      @product_rating = ProductRating.find_or_initialize_by(
        user: current_user,
        product: @product
      )
    end
  end

  def create
    # Post.newは初期化
    # post_paramsという引数 = キー(カラム)と値を渡してPostオブジェクトを初期設定する
    @post = current_user.posts.new(post_params)
    # @post.product = @product if @product.present?

    if @product.present? && params[:post][:product_rating].present?
      # 「Productが紐づいているか」を調べたい.:postのコレクションの中の:product_idの値を探している
      @product_rating = ProductRating.find_or_initialize_by(
        user: current_user,
        product: @product
      )

      # 評価値パラメータを手動で割り当ててバリデーションに備える
      # rating_params は privateメソッドで定義
      @product_rating.assign_attributes(rating_params)
    end

    # バリデーションチェック両方満たせば保存という流れ
    post_valid = @post.valid?
    rating_valid = @product.present? ? @product_rating.valid? : true

    if post_valid && rating_valid
      # Postの保存
      @post.save!

      # ProductRatingの保存または更新 (Upsert)
      # valid?チェック済みなので save! で安全に保存
      @product_rating.save! if @product.present?

      redirect_to posts_path, success: "投稿が完了しました！"
    else
      flash.now[:danger] = "投稿に失敗しました"
      # HTTPステータスコードを422に設定
      # 422:リクエストは理解したがその内容がアプリケーションのルール（バリデーション）を満たさなかった
      # render :newにより、入力済みの項目は残る
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if @post.user == current_user
      @post.destroy
      redirect_to posts_path, notice: "投稿を削除しました"
    else
      redirect_to posts_path, alert: "権限がありません"
    end
  end

  private

  def post_params
    params.require(:post).permit(
      :product_id,
      :product_name,
      :body,
      images: []
    )
  end

  # ProductRating専用のパラメータ（params[:post][:product_rating]から取得）
  def rating_params
    # :post配下のパラメータから:product_ratingキーの値を取得
    params.require(:post).fetch(:product_rating, {}).permit(
      :aroma,
      :taste,
      :price
    )
  end

  # @productを設定するための共通メソッド
  def set_product_from_params
    # createアクションではparams[:product_id] (URLパラメータ)は空になるため、右のフォームデータのチェックに進む
    product_id = params[:product_id] || (params[:post] ? params[:post][:product_id] : nil)
    if product_id.present?
      @product = Product.find(product_id)
    else
      @product = nil
    end
  end
end
