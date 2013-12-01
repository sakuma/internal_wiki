class PasswordResetsController < ApplicationController

  layout 'login'
  skip_before_action :require_login
  before_action :set_user_from_token, only: %i[edit update]

  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    @user.deliver_reset_password_instructions! if @user
    redirect_to root_path, notice: t('terms.please_confirm_sent_email_for_newpassword', email: @user.email)
  end

  def edit
  end

  def update
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.change_password!(params[:user][:password])
      redirect_to root_path, notice: t('terms.successfully_update_password')
    else
      render :edit
    end
  end


  private

  def set_user_from_token
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])
    not_authenticated unless @user
    @user.on_reset_password = true
  end
end
