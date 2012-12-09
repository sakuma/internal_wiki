class WikiInformationObserver < ActiveRecord::Observer
  require 'fileutils'

  def after_create(wiki_info)
    Grit::Repo.init(WikiInformation::BASE_GIT_DIRECTORY.join("#{wiki_info.name}.git").to_s)
    wiki_info.pages.create(:name => 'Welcome', :body => 'Getting started guide')
  end

  def after_destroy(wiki_info)
    FileUtils.rm_rf(wiki_info.git_directory)
  end

end
