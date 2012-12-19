class SessionsController < ApplicationController
  skip_before_filter :require_login
  layout 'login'

  def new
    @user = User.new
  end

  def create
    user = login(params[:email_or_name], params[:password], params[:remember_me])
    if user
      flash[:notice] = t('terms.successfully_login')
      redirect_back_or_to(root_path)
    else
      flash.now[:warning] = t('terms.invalid_email_or_name_or_password')
      render :new
    end
  end

  def destroy
    logout
    redirect_to login_path, :notice => t('terms.logged_out')
  end
end
