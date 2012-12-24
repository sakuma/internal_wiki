class User < ActiveRecord::Base

  attr_protected :id, :updated_at, :created_at

  attr_accessor :password, :password_confirmation

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :private_memberships, :dependent => :destroy
  has_many :private_wiki_informations, :through => :private_memberships, :source => :wiki_information
  has_many :visibilities, :dependent => :destroy
  has_many :visible_wikis, :through => :visibilities, :source => :wiki_information
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  scope :visible_wiki_candidates_on, ->(wiki) do
    where(["NOT id IN (?)", wiki.visible_authority_users.pluck("users.id")])
  end
  scope :not_admin, ->{ where(:admin => false) }

  validates :name, :presence => true, :uniqueness => true
  validates :email, :presence => true, :uniqueness => true

  validates_inclusion_of :admin, :in => lambda{|u| u.admin_validetes_include_values}, :message => :invalid_admin_select
  validates_inclusion_of :limited, :in => lambda{|u| u.limited__validetes_include_values}, :message => :invalid_limited_select

  def unvisible_wikis
    WikiInformation.all - visible_wikis
  end

  def admin_validetes_include_values
    limited? ? [false] : [true, false]
  end

  def limited__validetes_include_values
    admin? ? [false] : [true, false]
  end

end
