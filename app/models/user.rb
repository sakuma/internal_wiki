class User < ActiveRecord::Base

  attr_accessible :name, :email, :salt, :admin, :limited, :password, :password_confirmation

  attr_accessor :password, :password_confirmation

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  # has_many :private_memberships, dependent: :destroy
  # has_many :private_wiki_informations, through: :private_memberships, source: :wiki_information
  has_many :visibilities, dependent: :destroy
  has_many :visible_wikis, through: :visibilities, source: :wiki_information
  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  scope :visible_wiki_candidates_on, ->(wiki) do
    where.not(id: wiki.visible_authority_users.pluck("users.id"))
  end
  scope :not_admin, ->{ where(admin: false) }
  scope :active, ->{ where(activation_state: 'active') }
  scope :pending, ->{ where(activation_state: 'pending') }

  validates_presence_of :name, on: :update
  validates :email, presence: true, uniqueness: true
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
    if activated?
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
