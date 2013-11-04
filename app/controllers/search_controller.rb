class SearchController < ApplicationController
  def index
    @search_word = params[:q]
    if @search_word.blank?
      @pages = []
    else
      params[:ids] = WikiInformation.accessible_by(current_user).map(&:id)
      @pages = Page.search(params)
    end
  end
end
