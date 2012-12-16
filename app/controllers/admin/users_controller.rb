class Admin::UsersController < ApplicationController
  before_filter :require_admin_user
  before_filter :find_user, :only => [:show, :edit, :update, :destroy, :add_visibility_wiki, :delete_visibility_wiki]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to admin_user_path(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to admin_user_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, :notice => 'successfully delete user.'
  end

  def add_visibility_wiki
    wiki = WikiInformation.where(:id => params[:wiki_id]).first
    @user.visible_wikis << wiki
    @user.reload
    redirect_to admin_user_path(@user), :notice => 'Add wiki'
  end

  def delete_visibility_wiki
    wiki = WikiInformation.where(:id => params[:wiki_id]).first
    @user.visible_wikis.delete(wiki)
    @user.reload
    redirect_to admin_user_path(@user), :notice => 'Add wiki'
  end


  private

  def find_user
    @user = User.find(params[:id])
  end

  def require_admin_user
    redirect_to root_path unless current_user.admin?
  end

end
