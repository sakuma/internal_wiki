class WikiInformation < ActiveRecord::Base

  attr_accessible :created_by, :is_private, :name

  has_many :pages, :dependent => :destroy
  has_many :private_memberships, :dependent => :destroy
  has_many :visible_authority_users, :through => :private_memberships, :source => :user
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'

  validates :name, :presence => true, :uniqueness => true

  before_update :rename_repository_directory

  BASE_GIT_DIRECTORY = Rails.root.join('data')

  scope :accessible_by, ->(user) do
    return all if user.admin?
    WikiInformation.where(:is_private => false) + user.private_memberships
  end

  def git_directory(overwrite_name = nil)
    BASE_GIT_DIRECTORY.join("#{overwrite_name or name}.git").to_s
  end

  def collaborator_for_private_wiki?(user)
    membership = private_memberships.find_by_user_id(user.id)
    return false unless membership
    return true if membership.admin?
    false
  end

  private

  def rename_repository_directory
    return unless self.name_changed?
    before, after = self.name_change
    File.rename(self.git_directory(before), self.git_directory(after))
  end

end
