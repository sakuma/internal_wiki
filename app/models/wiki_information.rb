class WikiInformation < ActiveRecord::Base

  attr_accessible :created_by, :is_private, :name

  has_many :pages
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'

  BASE_GIT_DIRECTORY = Rails.root.join('data')

  def git_directory
    BASE_GIT_DIRECTORY.join("#{self.name}.git")
  end

end
