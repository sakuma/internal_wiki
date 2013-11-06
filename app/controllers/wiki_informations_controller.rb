class WikiInformationsController < ApplicationController

  before_filter :reject_limited_user, except: %i[index show]
  before_filter :find_wiki_info, only: %i[show edit update destroy add_authority_user remove_authority_user visible_wiki_candidates_users]

  def index
    @wiki_informations = WikiInformation.accessible_by(current_user)
  end

  def show
  end

  def new
    @wiki_info = WikiInformation.new
  end

  def edit
  end

  def create
    @wiki_info = WikiInformation.new(params[:wiki_information].merge(created_by: current_user.id))

    if @wiki_info.save
      redirect_to wiki_info_path(wiki_name: @wiki_info.name), notice: t('terms.created_wiki')
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @wiki_info.update_attributes(params[:wiki_information])
        format.html { redirect_to edit_wiki_info_path(wiki_name: @wiki_info.name), notice: t('terms.updated_wiki')}
        format.json { head :no_content }
      else
        format.html { render :edit}
        format.json { render json: @wiki_information.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @wiki_info.destroy
    redirect_to root_path
  end

  def add_authority_user
    result = {success: '', failed: ''}
    user = User.active.where(email: params[:email]).first!
    user.visible_wikis << @wiki_info
    @wiki_info.visible_authority_users << user
    result[:success] = "Added #{user.name}"
  rescue => e
    logger.warn "Failed add user: #{e.message}"
    result[:failed] = "Failed add user: #{e.message}"
  ensure
    if request.xhr?
      render partial: 'private_members', layout: false
    else
      redirect_to edit_wiki_info_path(wiki_name: @wiki_info.name), notice: result[:success], error: result[:failed]
    end
  end

  def remove_authority_user
    result = {success: '', failed: ''}
    user = User.active.where(email: params[:email]).first!
    user.visibilities.find_by(wiki_information_id: @wiki_info.id).destroy!
    @wiki_info.private_memberships.find_by(user_id: user.id).destroy!
    result[:success] = "Removed #{user.name}"
  rescue => e
    logger.warn "Failed remove user #{user.name}: #{e.message}"
    result[:failed] = "Failed remove user #{user.name}"
  ensure
    if request.xhr?
      render partial: 'private_members', layout: false
    else
      redirect_to edit_wiki_info_path(wiki_name: @wiki_info.name), notice: result[:success], error: result[:failed]
    end
  end

  def visible_wiki_candidates_users
    users = User.active.visible_wiki_candidates_on(@wiki_info)
    users = users.where("users.email LIKE :email OR users.name LIKE :name", email: "%#{params[:q]}%", name: "%#{params[:q]}%") if params[:q].present?
    email_list = users.map {|user| {value: "#{user.email} (#{user.name.truncate(15)})", tokens: [user.email, user.name] }}
    render json: email_list, layout: false
  end


  private

  def find_wiki_info
    @wiki_info = WikiInformation.where(name: params[:wiki_name]).first
  end

  def reject_limited_user
    if current_user.limited?
      redirect_to root_path and return
    end
    true
  end
end
