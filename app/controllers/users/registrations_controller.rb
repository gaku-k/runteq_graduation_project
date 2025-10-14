# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # createアクション(=新規作成/sign_up)が実行される前に以下のメソッドが呼ばれる
  before_action :configure_sign_up_params, only: [ :create ]
  # updateではユーザーのcurrent_passwordを求める。その他必須パラメーターに違いがあるのでcreateとupdateで場合わけする
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    # 継承しているデフォルトコントローラーにも同名のメソッドがある
    # def createの中にsuperだけを記述している場合、「基本のサインアップ処理はDeviseに任せる」という意味になる。
    super # <---- これがDevise::RegistrationsController#createを呼び出す
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    # デフォルトパラメータに加えてnameカラムを許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # アカウント更新時に送信されるパラメータを許可
  def configure_account_update_params
    # パスワードを変更せずに名前だけを更新できるよう :nameを許可する
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # サインアップ成功後の遷移先を指定。コメントアウトかsuper(resource)だけならDeviseのデフォルト動作となる
  def after_sign_up_path_for(resource)
    # ユーザーがアクセスしようとしていたページ(Stored Location)か、それがなければルートURLに移動する
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
