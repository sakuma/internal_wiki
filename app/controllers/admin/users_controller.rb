class Admin::UsersController < ApplicationController
  before_filter :require_admin_user
  before_filter :find_user, only: %i(show edit update destroy add_visibility_wiki delete_visibility_wiki candidates_wiki resend_invite_mail unlock)

  def index
    @active_users = User.active
    @invalidity_users = User.pending
    @locked_users = User.locked
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_user_path(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to admin_user_path(@user), notice: t('terms.updated_user_info')
    else
      render :edit
    end
  end

  def destroy
    if @user.pending? or @user.deleted?
      @user.destroy!
      message = t('terms.deleted_user_info')
    else
      @user.destroy
      message = t('terms.locked_user_info')
    end
    redirect_to admin_users_path, notice: message
  end

  def unlock
    @user.unlock!
    redirect_to admin_users_path, notice: t('terms.unlocked_user_info')
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
      redirect_to admin_users_path, alert: t('terms.vailed_invite_mail_of', email: user.email)
    end
  end

  def resend_invite_mail
    @user.reset_activation!
    UserMailer.activation_needed_email(@user).deliver
    redirect_to admin_users_path, notice: t('terms.resent_invite_mail_of', email: @user.email)
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def find_user
    user_scope = User.all
    user_scope = user_scope.with_deleted if %w(unlock destroy).include?(params[:action])
    @user = user_scope.find_by!(id: params[:id])
  end

  def require_admin_user
    redirect_to root_path unless current_user.admin?
  end

  def build_invite_user
    User.new(user_params.merge(name: '', password: 'sample', password_confirmation: 'sample'))
  end

end
