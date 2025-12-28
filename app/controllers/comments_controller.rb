class CommentsController < ApplicationController
  before_action :set_commentable, only: [ :create ]
  def create
    # もしフォームからparent_idが送られてきたら(概念。Commentsテーブルにはないがancestryを計算するための材料になる)
    if params[:parent_id]
      parent = Comment.find(params[:parent_id])
      # 親への返信を生成するための箱を用意。ancestryが追加してくれるメソッド
      @comment = parent.children.build(comment_params)
      @comment.commentable = @commentable
    else
      @comment = @commentable.comments.build(comment_params)
    end

    @comment.user = current_user

    if @comment.save
      redirect_to @commentable, notice: "コメントを投稿しました。"
    else
      redirect_to @commentable, danger: "コメントの投稿に失敗しました。"
    end
  end

  def destroy
  end

  private

  def comment_params
    params.require(:comment).permit(
      :body,
      :parent_id
    )
  end

  # ルーティングにより親リソース(Post/Product)の下にネストされた状態でリクエストされる.どちらの親から来たのかを判定する処理が必要
  def set_commentable
    if params[:post_id]
      @commentable = Post.find(params[:post_id])
    elsif params[:product_id]
      @commentable = Product.find(params[:product_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
