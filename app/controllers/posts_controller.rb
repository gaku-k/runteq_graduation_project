class PostsController < ApplicationController
  # 1ページあたりの件数
  BOOK_COUNT = 24
  # before_action :autenticate_uer! メソッド: Deviseが提供する「ログインしていなければログインページにリダイレクトする」
  # except :ただし/除く
  before_action :authenticate_user!, except: [ :index, :show ]

  def index
    # @params[:q]に検索フォームから送られたパラメータが入る.
    @q = Post.ransack(params[:q])
    # resultメソッドはparams[:q]がnilなら全件(Post.all)を返す
    # distinct: true 同じレコードが重複して出ないようにするオプション
    @posts = @q.result(distinct: true)
               # 絞り込みした結果に基づくユーザーとアバターを一括で読み込む
               .includes(user: { avatar_attachment: :blob })
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
    @post = Post.new

    # 「この商品でPostする」からの遷移を想定
    if params[:product_id]
      @product = Product.find(params[:product_id])
      @post.product_name = @product.name
      # showページで商品名をリンク化するのでidも保持させる
      @post.product_id = @product.id
    end
  end

  def create
    # Post.newは初期化
    # post_paramsという引数 = キー(カラム)と値を渡してPostオブジェクトを初期設定する
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
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
      :aroma_rating,
      :taste_rating,
      :price_rating,
      images: []
    )
  end
end
