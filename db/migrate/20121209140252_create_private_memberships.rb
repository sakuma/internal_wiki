class CreatePrivateMemberships < ActiveRecord::Migration
  def change
    create_table :private_memberships do |t|
      t.integer :user_id
      t.integer :wiki_information_id
      t.boolean :admin, :null => false, :default => false

      t.timestamps
    end

    add_index :private_memberships, [:user_id, :wiki_information_id], :unique => true
  end
end
