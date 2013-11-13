class PagesController < ApplicationController
  layout :get_layout

  before_action :find_wiki_information, only: [:index, :show, :new, :create, :edit, :update, :destroy, :histories, :revert, :preview]
  before_action :find_page, only: [:show, :edit, :update, :destroy, :histories, :revert]

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
    @page = @wiki_info.pages.build(page_params.merge(updated_by: current_user.id))
    if @page.save
      redirect_to page_path(wiki_name: @wiki_info.name, page_name: @page.url_name), notice: t('terms.created_page')
    else
      render :new
    end
  end

  def update
    if params[:page].blank?
      render nothing: true
      return
    end
    respond_to do |format|
      if @page.update_attributes(page_params.merge(updated_by: current_user.id))
        body = @page.body
        parsed_body = @page.formatted_preview
        PrivatePub.publish_to "/pages/#{@page.id}", body: body, parsed_body: parsed_body, editing_word: '' rescue nil
        format.html { redirect_to page_path(wiki_name: @wiki_info.name, page_name: @page.url_name), notice: t('terms.updated_page') }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def preview
    # TODO: リファクタリング
    if params[:page_name]
      @page = @wiki_info.pages.where(url_name: params[:page_name]).first
      if params[:previewed]
        body = params[:body]
        parsed_body = @page.formatted_preview(body)
        editor = User.find_by(id: params[:edited_user_id].to_i)
        PrivatePub.publish_to "/pages/#{@page.id}", body: body, parsed_body: parsed_body,
        edited_user_id: current_user.id.to_s,
          editing_word: editor ? I18n.t('terms.editing_by', target: editor.name) : ''
      else
        parsed_body = @page.formatted_preview
      end
    else # new page
      parsed_body = @wiki_info.pages.build.formatted_preview(params[:body])
    end
    render text: parsed_body, layout: false
  end

  def destroy
    @page.destroy_by(current_user)
    redirect_to wiki_info_path(wiki_name: @wiki_info.name), notice: t('terms.deleted_page')
  end

  def revert
    if @page.revert(current_user, params[:sha])
      redirect_to page_path(wiki_name: @wiki_info.name, page_name: @page.url_name), notice: t('terms.reverted_to', target: @page.date(params[:sha]).to_s(:db))
    else
      render :histories
    end
  end


  private

  def page_params
    params.require(:page).permit(:name, :url_name, :body)
  end

  def find_wiki_information
    @wiki_info = WikiInformation.where(name: params[:wiki_name]).first!
  end

  def find_page
    @page = @wiki_info.pages.where(url_name: params[:page_name]).first
  end

end
