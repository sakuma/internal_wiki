class User < ActiveRecord::Base
  authenticates_with_sorcery!

  attr_accessor :password, :password_confirmation

  has_many :private_memberships, :dependent => :destroy
  has_many :private_wiki_informations, :through => :private_memberships, :source => :wiki_information
  has_many :visibilities, :dependent => :destroy
  has_many :visible_wikis, :through => :visibilities, :source => :wiki_information

end
