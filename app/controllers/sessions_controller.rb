class SessionsController < ApplicationController
  skip_before_filter :require_login
  layout 'login'

  def new
    @user = User.new
  end

  def create
    user = login(params[:email], params[:password])
    if user
      flash[:notice] = 'Successful logged in.'
      redirect_back_or_to(root_path)
    else
      render :new
    end
  end

  def destroy
    logout
    redirect_to login_path, :notice => 'logout.'
  end
end
