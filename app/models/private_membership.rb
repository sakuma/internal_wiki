class PrivateMembership < ActiveRecord::Base
  attr_accessible :admin, :user_id, :wiki_information_id

  belongs_to :user
  belongs_to :wiki_information

end
