class CreateVisibilities < ActiveRecord::Migration
  def change
    create_table :visibilities do |t|
      t.integer :user_id
      t.integer :wiki_information_id

      t.timestamps
    end
    add_index :visibilities, [:user_id, :wiki_information_id], :unique => true
  end
end
