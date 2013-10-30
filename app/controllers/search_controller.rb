class SearchController < ApplicationController
  def index
    @search_word = params[:q]
    if @search_word.blank?
      @pages = []
    else
      @pages = Page.search(params[:q], load: true)
    end
  end
end
