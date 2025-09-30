class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
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
