class WikiInformation < ActiveRecord::Base

  PermissionError = Class.new(StandardError)
  BASE_GIT_DIRECTORY = Rails.root.join(Settings.data_dir.wiki).freeze
  RESERVED_NAMES = %w(admin setting search).freeze

  has_many :pages, dependent: :destroy
  has_many :visibilities, dependent: :destroy
  has_many :visible_users, through: :visibilities, source: :user
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'

  validates :name, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9]([-a-z0-9]+)?\Z/i, message: :wrong_format_wiki_name},
    length: { maximum: 50 }, exclusion: { in: RESERVED_NAMES }

  before_save :set_visivilities
  before_create :prepare_git_repository
  before_update :rename_repository_directory
  after_create :setup_home_page
  after_destroy :cleanup_git_repository
  after_update :clear_private_memberships, if: Proc.new{|w| w.public? }

  scope :accessible_by, ->(user) do
    if user.guest?
      user.visible_wikis
    else
      WikiInformation.includes(:visibilities).where(
        "visibilities.user_id = ? OR wiki_informations.is_private = ?", user.id, false
      ).references(:visibilities)
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
    visibilities.find_by(user_id: user.id).present?
  end

  def welcome_page
    pages.where(url_name: 'welcome').first
  end

  def publish_by!(user)
    raise PermissionError if user.nil? || user.guest?
    update_attributes!(is_private: false, updated_by: user.id)
  end

  def hide_by!(user)
    raise PermissionError if user.nil? || user.guest?
    update_attributes!(is_private: true, updated_by: user.id)
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

  def set_visivilities
    return unless private?
    if new_record?
      visibilities.build(user_id: created_by)
    else
      visibilities.find_or_initialize_by(user_id: updated_by)
    end
  end

  def setup_home_page
    self.pages.create(url_name: 'welcome', name: 'Welcome', body: 'Getting started guide', updated_by: self.created_by)
  end

  def cleanup_git_repository
    FileUtils.rm_rf(self.git_directory)
  rescue => e
    logger.warn "Failed Cleanup Git Repository: #{e.message}"
  end

  # guest ユーザは閲覧性を保持し、それ以外のユーザには開放する
  def clear_private_memberships
    Visibility.where(wiki_information_id: self.id).includes(:user).
      where(users: {limited: false}).references(:users).destroy_all
  end

end
