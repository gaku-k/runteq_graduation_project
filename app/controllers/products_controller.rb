class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to product_path(@product), success: "ご協力ありがとうございます！"
    else
      flash.now[:danger] = "商品追加に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :country_of_origin,
      :volume,
      :reference_price,
      :sweet_rating,
      :spicy_rating,
      :bitter_rating,
      :green_rating,
      :fruity_rating,
      images: []
    )
  end
end
