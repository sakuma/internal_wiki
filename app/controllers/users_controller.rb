class UsersController < ApplicationController
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
end
