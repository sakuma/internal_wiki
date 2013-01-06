class SearchController < ApplicationController
  def index
    @search_word = params[:query]
    result = Groonga::Page.select{|page| page.body =~ @search_word}
    @pages = Page.where(['id IN(?)', result.map(&:page_id)])
  end
end
