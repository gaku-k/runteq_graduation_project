class CommentsController < ApplicationController
  before_acrion :set_commentable, only: [ :create ]
  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @commentable, notice: "コメントを投稿しました。"
    else
      redirect_to @commentable, alert: "コメントの投稿に失敗しました。"
    end
  end

  def destroy
  end

  private

  def comment_params
    params.require(:comment).permit(
      :body
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
