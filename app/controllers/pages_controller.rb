class PagesController < ApplicationController
  layout :get_layout

  before_action :find_wiki_information, only: [:index, :list_view_index, :globe_view_index, :show, :new, :create, :edit, :update, :destroy, :histories, :revert, :preview, :attachment, :file_upload, :file_destroy]
  before_action :find_page, only: [:show, :edit, :update, :destroy, :histories, :revert, :attachment, :file_upload, :file_destroy]
  before_action :find_sample_page, only: [:index, :list_view_index, :globe_view_index]
  before_action :find_attachment, only: [:attachment, :file_destroy]

  def index
  end

  def list_view_index
    render partial: 'list_view_index', layout: false
  end

  def globe_view_index
    render partial: 'globe_view_index', layout: false
  end

  def new
    @page = @wiki_info.pages.build
  end

  def edit
  end

  def help
  end

  def show
    @files = @page.attachments
    @attachment = Attachment.new
  end

  def histories
    @former_page = @page.raw_content(params[:sha].present? ? params[:sha] : nil)
  end

  def revert
    if @page.revert(current_user, params[:sha])
      redirect_to page_path(wiki_name: @wiki_info.name, page_name: @page.url_name), notice: t('terms.reverted_to', target: @page.date(params[:sha]).to_s(:db))
    else
      render :histories
    end
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
      render nothing: true and return
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
        PrivatePub.publish_to("/pages/#{@page.id}", body: body, parsed_body: parsed_body,
          edited_user_id: current_user.id.to_s,
          editing_word: editor ? I18n.t('terms.editing_by', target: editor.name) : '') rescue nil
      else
        data =  params[:sha].present? ? @page.raw_content(params[:sha]) : nil
        parsed_body = @page.formatted_preview(data)
      end
    else # new page
      parsed_body = @wiki_info.pages.build.formatted_preview(params[:body])
    end
    render text: parsed_body, layout: false
  end

  def destroy
    if @page.destroy_by(current_user)
      redirect_to wiki_info_path(wiki_name: @wiki_info.name), notice: t('terms.deleted_page')
    else
      redirect_to wiki_info_path(wiki_name: @wiki_info.name), alert: t('terms.do_not_delete_page')
    end
  end

  def attachment
    file_path = Rails.root.join(@file.attachment.path).to_s
    send_file(file_path, type: @file.attachment_content_type)
  end

  def file_upload
    @file = @page.attachments.build(attachment_params)
    if attachment_params.present? && @file.save
      message = {notice: "success"}
    else
      message = {alert: "failed"}
    end
    redirect_to page_path(wiki_name: @wiki_info.name, page_name: @page.url_name), message
  end

  def file_destroy
    @file = @page.attachments.find_by(id: params[:id])
    @file.destroy
    redirect_to page_path(wiki_name: @wiki_info.name, page_name: @page.url_name), notice: 'deleted'
  end

  private

  def page_params
    params.require(:page).permit(:name, :url_name, :body)
  end

  def attachment_params
    return nil unless params[:attachment].present?
    params.require(:attachment).permit(:attachment)
  end

  def find_wiki_information
    @wiki_info = WikiInformation.where(name: params[:wiki_name]).first!
  end

  def find_page
    @page = @wiki_info.pages.where(url_name: params[:page_name]).first!
  rescue => e
    logger.warn "Error find page: #{e.message}"
    redirect_to wiki_path(wiki_name: @wiki_info.name), alert: t('terms.not_found_page_of', page: params[:page_name])
  end

  def find_sample_page
    @pages = @wiki_info.pages.sample(70)
  end

  def find_attachment
    @file = @page.attachments.find_by(id: params[:id])
  end

end
