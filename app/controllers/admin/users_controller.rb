class Admin::UsersController < ApplicationController
  before_filter :require_admin_user
  before_filter :find_user, :only => [:show, :edit, :update, :destroy, :add_visibility_wiki, :delete_visibility_wiki, :candidates_wiki, :resend_invite_mail]

  def index
    @active_users = User.active.all
    @invalidity_users = User.pending.all
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
    redirect_to admin_users_path, notice: t('terms.deleted_user_info')
  end

  def add_visibility_wiki
    wiki = WikiInformation.find_by(name: params[:wiki_name])
    @user.visible_wikis << wiki
    @user.reload
    redirect_to admin_user_path(@user), notice: t('terms.candidates_wiki_of', wiki: wiki.name)
  end

  def delete_visibility_wiki
    wiki = WikiInformation.find_by(id: params[:wiki_id])
    @user.visible_wikis.delete(wiki)
    @user.reload
    redirect_to admin_user_path(@user), notice: t('terms.unvisible_wiki_of', wiki: wiki.name)
  end

  def candidates_wiki
    unvisible_wiki_list = @user.unvisible_wikis
    wikiname_list = unvisible_wiki_list.map {|wiki| {value: wiki.name, tokens: [wiki.name] }}
    render json: wikiname_list, layout: false
  end

  def invite_user
    user = build_invite_user
    if user.valid? and user.save(validate: false)
      redirect_to admin_users_path, notice: t('terms.sent_invite_mail_of', email: user.email)
    else
      flash[:error] = t('terms.vailed_invite_mail_of', email: user.email)
      redirect_to admin_users_path
    end
  end

  def resend_invite_mail
    UserMailer.activation_needed_email(@user).deliver
    redirect_to admin_users_path, notice: t('terms.resent_invite_mail_of', email: @user.email)
  end


  private

  def find_user
    @user = User.find(params[:id])
  end

  def require_admin_user
    redirect_to root_path unless current_user.admin?
  end

  def build_invite_user
    User.new(params[:user].merge(name: '', password: 'sample', password_confirmation: 'sample'))
  end

end
