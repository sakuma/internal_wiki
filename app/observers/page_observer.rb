class PageObserver < ActiveRecord::Observer

  def after_create(page)
    create_groonga_record(page)
  end

  def after_update(page)
    if groonga_page = Groonga::Page.find("#{page.id}_#{page.name}")
      groonga_page.body = page.body
      groonga_page.save
      Rails.logger.info "\n === Updated groonga record for #{page.inspect}\n"
    else
      create_groonga_record(page)
    end
  end

  private

  def create_groonga_record(page)
    Groonga::Page.create(key: "#{page.id}_#{page.name}", page_id: page.id, wiki_information_id: page.wiki_information_id, body: page.body)
    Rails.logger.info "\n === Created groonga record for #{page.inspect}\n"
  end
end
