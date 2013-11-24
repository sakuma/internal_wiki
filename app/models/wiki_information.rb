class WikiInformation < ActiveRecord::Base

  attr_accessible :created_by, :is_private, :name

  has_many :pages, :dependent => :destroy
  has_many :private_memberships, :dependent => :destroy
  has_many :visible_authority_users, :through => :private_memberships, :source => :user
  has_many :visibilities, :dependent => :destroy
  has_many :visible_wikis, :through => :visibilities, :source => :user
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'

  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]([-a-z0-9]+)?\Z/i, message: :wrong_format_wiki_name}, length: { maximum: 50 }

  before_create :prepare_git_repository
  before_update :rename_repository_directory
  after_create :setup_home_page
  after_destroy :cleanup_git_repository
  after_update :clear_private_memberships, if: Proc.new{|w| w.public? }

  BASE_GIT_DIRECTORY = Rails.root.join(Settings.wiki_data_dir)

  scope :accessible_by, ->(user) do
    if user.admin?
      all
    elsif user.limited
      user.visible_wikis
    else
      WikiInformation.where(:is_private => false) + user.private_wiki_informations
    end
  end

  def private?
    is_private?
  end

  def public?
    not is_private?
  end

  def git_directory(overwrite_name = nil)
    BASE_GIT_DIRECTORY.join("#{overwrite_name or name}.git").to_s
  end

  def collaborator_for_private_wiki?(user)
    if user.guest?
      return visibilities.find_by(user_id: user.id).present?
    end
    return true if public?
    private_memberships.find_by(user_id: user.id).present?
  end

  def welcome_page
    pages.where(url_name: 'welcome').first
  end

  private

  def rename_repository_directory
    return unless name_changed?
    FileUtils.rm_rf(git_directory) if File.exists? git_directory
    File.rename(git_directory(name_was), git_directory(name))
  end

  def prepare_git_repository
    FileUtils.rm_rf(git_directory) if File.exists? git_directory
    Grit::Repo.init(git_directory)
  end

  def setup_home_page
    self.pages.create(url_name: 'welcome', name: 'Welcome', body: 'Getting started guide', updated_by: self.created_by)
    if is_private?
      self.private_memberships.create(user_id: self.created_by)
    end
  end

  def cleanup_git_repository
    FileUtils.rm_rf(self.git_directory)
  rescue => e
    logger.warn "Failed Cleanup Git Repository: #{e.message}"
  end

  def clear_private_memberships
    private_memberships.delete_all
    visibilities.delete_all
  end

end
