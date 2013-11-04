class SearchController < ApplicationController
  def index
    if params[:q].blank?
      @pages = []
    else
      @search_word = params[:q].split(' ')
      params[:ids] = WikiInformation.accessible_by(current_user).map(&:id)
      @pages = Page.search(params)
    end
  end
end
