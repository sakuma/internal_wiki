class Visibility < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki_information
end
