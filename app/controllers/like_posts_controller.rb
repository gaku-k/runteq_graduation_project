class LikePostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    current_user.like_posts.create!(post: @post)
  end

  def destroy
    current_user.like_posts.find_by(post: @post)&.destroy
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
