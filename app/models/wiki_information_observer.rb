class WikiInformationObserver < ActiveRecord::Observer
  require 'fileutils'

  def after_create(wiki_info)
    Grit::Repo.init(wiki_info.git_directory)
    wiki_info.pages.create(:name => 'Welcome', :body => 'Getting started guide', :updated_by => wiki_info.created_by)

    if wiki_info.is_private
      wiki_info.private_memberships.create(:user_id => wiki_info.created_by, :admin => true)
    end
  end

  def after_destroy(wiki_info)
    FileUtils.rm_rf(wiki_info.git_directory)
  end

end
