class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if current_user.update(profile_params)
      # 新規アバターがあればwebp化処理
      @user.convert_images_to_webp! if profile_params[:avatar].present?
      redirect_to my_page_path, notice: "プロフィールを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :avatar)
  end
end
