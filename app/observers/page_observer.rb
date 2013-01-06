class PageObserver < ActiveRecord::Observer

  def after_create(page)
    Groonga::Page.create(key: "#{page.wiki_information_id}_#{page.name}", body: page.body)
  end

  def after_update(page)
    groonga_page = Groonga::Page.find("#{page.wiki_information_id}_#{page.name}")
    return unless groonga_page
    groonga_page.body = page.body
    groonga_page.save
  end
end
