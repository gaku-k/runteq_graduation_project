class PostsController < ApplicationController
  # before_action :autenticate_uer! メソッド: Deviseが提供する「ログインしていなければログインページにリダイレクトする」
  # except :ただし/除く
  before_action :authenticate_user!, except: [ :index, :show ]

  def index
    # @params[:q]に検索フォームから送られたパラメータが入る.
    @q = Post.ransack(params[:q])
    # resultメソッドはparams[:q]がnilなら全件(Post.all)を返す
    # distinct: true 同じレコードが重複して出ないようにするオプション
    @posts = @q.result(distinct: true)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    # 空のPostオブジェクトを作成
    @post = Post.new
    # @post.bodyはnilとなる
  end

  def create
    # Post.newは初期化
    # post_paramsという引数 = キー(カラム)と値を渡してPostオブジェクトを初期設定する
    @post = Post.new(post_params)
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

  private

  def post_params
    params.require(:post).permit(
      :product_name,
      :body,
      :aroma_rating,
      :taste_rating,
      :price_rating,
      images: []
    )
  end
end
