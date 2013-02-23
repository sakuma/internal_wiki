class ChangeColumnsUsers < ActiveRecord::Migration
  def up
    change_column :users, :name,  :string
    change_column :users, :email, :string, :null => false
  end

  def down
    change_column :users, :name,  :string, :null => false
    change_column :users, :email, :string, :default => nil
  end
end
