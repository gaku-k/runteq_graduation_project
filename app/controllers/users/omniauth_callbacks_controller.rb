# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # Googleで認証が成功したとき、Googleから受け取ったデータで実際にログイン処理を行う窓口
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    # @userがデータベースに存在すれば
    if @user.persisted?
      # deviseのメソッド/ユーザーをログイン状態にしてトップページor直前見ていたページへ遷移
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      redirect_to new_user_registration_url
    end
  end

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
