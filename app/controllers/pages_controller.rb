class PagesController < ApplicationController
  layout :get_layout

  before_filter :find_wiki_information, :only => [:index, :show, :new, :create, :edit, :update, :destroy]
  before_filter :find_page, :except => [:index, :new, :show, :create]
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
    @page = @wiki_info.pages.find(params[:id] || Page.welcome)
  end

  def create
    @page = @wiki_info.pages.build(params[:page].merge(:updated_by => current_user.id))
    if @page.save
      flash[:notice] = "Successfully created page."
      redirect_to wiki_information_page_path(@wiki_info, @page)
    else
      render :action => 'new'
    end
  end

  def update
    if @page.update_attributes(params[:page].merge(:updated_by => current_user.id))
      redirect_to [@wiki_info, @page], :notice => "Successfully updated page."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @page.destroy
    redirect_to wiki_information_path(@wiki_info), :notice => "Successfully destroyed page."
  end

  def preview
    render :text => @page.preview(params[:data])
  end

  private

  def find_wiki_information
    @wiki_info = WikiInformation.find(params[:wiki_information_id])
  end

  def find_page
    @page = @wiki_info.pages.find(params[:id])
  end

  def find_body
    @page.body = params[:page][:body] rescue @page.raw_content
  end

end
