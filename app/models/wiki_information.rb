class WikiInformation < ActiveRecord::Base

  attr_accessible :created_by, :is_private, :name

  has_many :pages

  BASE_GIT_DIRECTORY = Rails.root.join('data')

  def git_directory
    BASE_GIT_DIRECTORY.join("#{self.name}.git")
  end

end
