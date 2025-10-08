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
      images: [],
      # 既存オリーブ品種の選択。配列によるデータ(id)の受け取りを許可し、既存データを再利用
      olive_variety_ids: [],
      # 別テーブルの新しい品種名を許可する
      olive_varieties_attributes: [ :name ]
      # ただしこれだけでは既存品種の再入力で同じ名前の別idのデータが送信できてしまう
    )
  end
end
