class UsersController < ApplicationController

  layout 'login', only: [:register, :activate]

  skip_before_filter :require_login, only: [:register, :activate]

  def setting
    @user = current_user
  end

  def update
    @user = User.find_by(id: params[:id])
    if @user.update_attributes(params[:user])
      redirect_to user_setting_path, notice: t('terms.updated_user_info')
    else
      render :setting
    end
  end

  def activate
    unless @user = User.load_from_activation_token(params[:token])
      flash[:error] = t('terms.invalid_activation_token')
      redirect_to login_path
    end
  end

  def register
    @user = User.load_from_activation_token(params[:token])
    if @user.update_attributes(params[:user])
      @user.activate!
      auto_login(@user)
      redirect_to root_path, notice: t('terms.registered_user_info')
    else
      render :activate
    end
  end

end
