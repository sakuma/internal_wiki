class User < ActiveRecord::Base

  never_wastes

  attr_accessor :password, :password_confirmation, :on_reset_password

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :visibilities, dependent: :destroy
  has_many :visible_wikis, through: :visibilities, source: :wiki_information
  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  scope :visible_wiki_candidates_on, ->(wiki) do
    where.not(id: wiki.visible_users.pluck("users.id"))
  end
  scope :not_admin, ->{ where(admin: false) }
  scope :active, ->{ where(activation_state: 'active') }
  scope :pending, ->{ where(activation_state: 'pending') }
  scope :locked, ->{ where(deleted: true) }

  validates_presence_of :name, on: :update
  validates :email, presence: true, uniqueness: true
  validates_inclusion_of :role, in: %w(admin member guest), message: :invalid_user_role
  validates_inclusion_of :admin, in: lambda{|u| u.admin_validetes_include_values}, message: :invalid_admin_select
  validates_inclusion_of :limited, in: lambda{|u| u.limited__validetes_include_values}, message: :invalid_limited_select
  validate :password_check

  def activated?
    activation_state == "active"
  end

  def pending?
    activation_state == "pending"
  end

  def guest?
    limited?
  end

  def unlock!
    self.deleted = false
    self.deleted_at = nil
    self.save!
  end

  def lock_or_destroy_by(operator)
    return "failed" if self == operator
    if pending? or deleted?
      self.demolish
      message = I18n.t('terms.deleted_user_info')
    else
      self.destroy
      message = I18n.t('terms.locked_user_info')
    end
    message
  end

  def self.role_list
    [%w(管理者 admin), %w(メンバー member), %w(ゲスト guest)]
  end

  def role
    if admin?
      'admin'
    elsif guest?
      'guest'
    else
      'member'
    end
  end

  def role=(role)
    case role
    when 'admin'
      self.admin = true
      self.limited = false
    when 'guest'
      self.limited = true
      self.admin = false
    else
      self.admin = false
      self.limited = false
    end
  end

  def activation_expired?
    return false if activated?
    pending? and activation_token_expires_at.try(:past?)
  end

  def unvisible_wikis
    WikiInformation.all - visible_wikis
  end

  def admin_validetes_include_values
    limited? ? [false] : [true, false]
  end

  def limited__validetes_include_values
    admin? ? [false] : [true, false]
  end

  def reset_activation!
    self.setup_activation
    self.save!(validate: false)
  end


  private

  def password_check
    if activated? && (not on_reset_password)
      return true if password.blank? && password_confirmation.blank?
    else # for activation
      unless password.present? && password_confirmation.present?
        errors.add :base, :blank_password
        return false
      end
    end
    errors.add :base, :unmatched_password unless password == password_confirmation
  end

end
