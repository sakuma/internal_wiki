class WikiInformationsController < ApplicationController

  before_filter :find_wiki_info, :only => [:show, :edit, :update, :destroy, :add_authority_user, :remove_authority_user]

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
    @wiki_info = WikiInformation.new(params[:wiki_information].merge(:created_by => current_user.id))

    if @wiki_info.save
      redirect_to wiki_info_path(wiki_name: @wiki_info.name), notice: 'Wiki information was successfully created.'
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @wiki_info.update_attributes(params[:wiki_information])
        format.html { redirect_to wiki_info_path(wiki_name: @wiki_info.name), notice: 'Wiki information was successfully updated.'}
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
    user = User.active.where(email: params[:email]).first
    @wiki_info.visible_authority_users << user if user
    redirect_to wiki_info_path(wiki_name: @wiki_info.name), notice: "added #{user.name}"
  end

  def remove_authority_user
    user = User.active.where(email: params[:email]).first
    member_ship = @wiki_info.private_memberships.find_by_user_id(user.id)
    member_ship.destroy
    redirect_to wiki_info_path(wiki_name: @wiki_info.name), notice: "removed #{user.name}"
  end

  def find_wiki_info
    @wiki_info = WikiInformation.where(name: params[:wiki_name]).first
  end
end
