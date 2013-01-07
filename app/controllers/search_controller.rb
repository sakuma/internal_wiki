class SearchController < ApplicationController
  def index
    @search_word = params[:q]
    if @search_word.blank?
      @pages = []
    else
      result = Groonga::Page.select{|page| page.body =~ @search_word}
      @pages = Page.where(['id IN(?)', result.map(&:page_id)])
    end
  end
end
