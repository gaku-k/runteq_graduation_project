class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    if params[:public_id]
      # !をつけないとnilとなり、見つからないまま@userをビューに渡す。@userを使う箇所でNoメソッドエラー
      # !をつけると例外を発生させ、404エラーを出す
      @user = User.find_by!(public_id: params[:public_id])
    else
      @user = current_user
      unless @user
        redirect_to new_user_session_path, alert: "ログインしてください"
      end
    end
  end
end
