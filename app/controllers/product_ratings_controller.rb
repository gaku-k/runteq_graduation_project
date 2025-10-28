class ProductRatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @product = Product.find(params[:product_id])
    @product_rating = @product.product_ratings.new(product_rating_params)
    @product_rating.user = current_user
    if @product_rating.save
      redirect_to product_path(@product), notice: "評価を投稿しました"
    else
      flash.now[:danger] = "評価に失敗しました"
      render "products/show", status: :unprocessable_entity
    end
  end

  def update
    @product = Product.find(params[:product_id])
    # 左側のproduct_id =テーブルのカラム名　右側のparams[:product_id] =URLやフォームに含まれるproduct_idパラメータ
    @product_rating = current_user.product_ratings.find_by!(product_id: params[:product_id], id: params[:id])
    if @product_rating.update(product_rating_params)
      redirect_to product_path(@product), notice: "評価を投稿しました"
    else
      flash.now[:danger] = "評価に失敗しました"
      render "products/show", status: :unprocessable_entity
    end
  end

  private

  def product_rating_params
    params.require(:product_rating).permit(
      :sweet,
      :spicy,
      :green,
      :fruity,
      :bitter
    )
  end
end
