class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
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
