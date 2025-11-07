class ContactsController < ApplicationController
  def new
    @contact = Contact.new

    if current_user
      @contact.user_id = current_user.id
      @contact.name = current_user.name
      @contact.email = current_user.email
    end
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to posts_path, success: "メッセージを送信しました！"
    else
      flash.now[:danger] = "投稿に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(
      :name,
      :email,
      :message,
      :inquire_type
    )
  end
end
