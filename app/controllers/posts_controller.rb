class PostsController < ApplicationController
  def index
    @posts = Post.all
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
