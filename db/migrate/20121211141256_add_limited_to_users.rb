class AddLimitedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :limited, :boolean, :default => false, :null => false
  end
end
