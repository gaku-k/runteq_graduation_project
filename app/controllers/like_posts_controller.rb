class LikePostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    current_user.like_posts.create!(post: @post)
    # ページリロードでいいねボタンの切り替わりを行う
    # 直前のページに戻る。もし戻り先がわからなければ、指定したページ（この場合は記事の詳細画面）へ行く
    redirect_back fallback_location: post_path(@post)
  end

  def destroy
    current_user.like_posts.find_by(post: @post)&.destroy
    redirect_back fallback_location: post_path(@post)
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
