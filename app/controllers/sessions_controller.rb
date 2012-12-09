class SessionsController < ApplicationController
  skip_before_filter :require_login
  layout 'login'

  def new
    @user = User.new
  end

  def create
    user = login(params[:email], params[:password])
    if user
      redirect_to root_path, :notice => 'Successful logged in.'
    else
      render :new
    end
  end

  def destroy
    logout
    redirect_to login_path, :notice => 'logoug.'
  end
end
