class UsersController < ApplicationController

  layout 'login', :only => [:register, :activate]

  skip_before_filter :require_login, :only => [:register, :activate]

  def new
    @user = User.new(params[:user])
  end

  def setting
    @user = current_user
  end

  def update
    @user = User.where(id: params[:id]).first
    if @user.update_attributes(params[:user])
      redirect_to user_setting_path, :notice => 'successfully update'
    else
      render :setting
    end
  end

  def activate
    unless @user = User.load_from_activation_token(params[:token])
      redirect_to login_path, error: 'Error'
    end
  end

  def register
    user = User.load_from_activation_token(params[:token])
    if user.update_attributes(params[:user])
      user.activate!
      auto_login(user)
      redirect_to root_path, notice: 'User was successfully activated.'
    else
      redirect_to login_path, error: 'Failed regist'
    end
  end

end
