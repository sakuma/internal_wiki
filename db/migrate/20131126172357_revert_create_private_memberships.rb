require_relative "20121209140252_create_private_memberships"

class RevertCreatePrivateMemberships < ActiveRecord::Migration
  def change
    revert CreatePrivateMemberships
  end
end
