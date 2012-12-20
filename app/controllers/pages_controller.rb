class PagesController < ApplicationController
  layout :get_layout

  before_filter :find_wiki_information, :only => [:index, :show, :new, :create, :edit, :update, :destroy, :preview]
  before_filter :find_page, :only => [:show, :edit, :update, :destroy, :preview]
  before_filter :find_body, :only => [:edit]

  def index
    @pages = @wiki_info.pages
  end

  def new
    @page = @wiki_info.pages.build
  end

  def edit
  end

  def show
  end

  def create
    @page = @wiki_info.pages.build(params[:page].merge(:updated_by => current_user.id))
    if @page.save
      redirect_to wiki_information_page_path(@wiki_info, @page), :notice => "Successfully created page."
    else
      render :new
    end
  end

  def update
    if params[:page].blank?
      render :nothing => true
      return
    end
    respond_to do |format|
      if @page.update_attributes(params[:page].merge(:updated_by => current_user.id))
        format.html do
          flash.now[:notice] = "Successfully updated page."
          redirect_to [@wiki_info, @page]
        end
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @page.destroy_by(current_user)
    redirect_to wiki_information_path(@wiki_info), :notice => "Successfully destroyed page."
  end

  def preview
    @preview = @page.preview(params[:page][:body])
    respond_to do |format|
      format.js
    end
  end


  private

  def find_wiki_information
    @wiki_info = WikiInformation.where(:id => params[:wiki_information_id]).first!
  end

  def find_page
    @page = @wiki_info.pages.where(:id => params[:id]).first
  end

  def find_body
    @page.body = params[:page][:body] rescue @page.raw_content
  end

end
