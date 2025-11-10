# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    # recoverableスコープ（admin除外）を通してユーザー検索
    self.resource = User.recoverable.find_by(email: resource_params[:email])

    if resource.present?
      # 通常のリセット処理
      resource.send_reset_password_instructions

      # true:メール送信成功
      if successfully_sent?(resource)
        respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      else
        respond_with(resource)
      end
    else
      # en.ymlのメッセージを抜き出している
      set_flash_message!(:notice, :send_paranoid_instructions)
      redirect_to new_user_session_path
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
