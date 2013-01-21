class PagesController < ApplicationController
  layout :get_layout

  before_filter :find_wiki_information, :only => [:index, :show, :new, :create, :edit, :update, :destroy, :histories, :revert, :preview]
  before_filter :find_page, :only => [:show, :edit, :update, :destroy, :histories, :revert, :preview]
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

  def histories
    @history_content = @page.content(params[:sha].blank? ? nil : params[:sha])
  end

  def create
    @page = @wiki_info.pages.build(params[:page].merge(:updated_by => current_user.id))
    if @page.save
      redirect_to wiki_information_page_path(@wiki_info, @page), :notice => t('terms.created_page')
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
        PrivatePub.publish_to "/pages/#{@page.id}", :body => params[:page][:body], :editing_word => '' rescue nil
        format.html { redirect_to [@wiki_info, @page], :notice => t('terms.updated_page') }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def preview
    @body = params[:body]
    @editor = User.where(id: params[:edited_user_id].to_i).first
    PrivatePub.publish_to "/pages/#{@page.id}", :body => @body,
      :editing_word => @editor ? I18n.t('terms.editing_by', :target => @editor.name) : ''
    render :nothing => true
  end

  def destroy
    @page.destroy_by(current_user)
    redirect_to wiki_information_path(@wiki_info), :notice => t('terms.deleted_page')
  end

  def revert
    if @page.revert(current_user, params[:sha])
      redirect_to [@wiki_info, @page], :notice => t('terms.reverted_to', :target => @page.date(params[:sha]).to_s(:db))
    else
      render :histories
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
