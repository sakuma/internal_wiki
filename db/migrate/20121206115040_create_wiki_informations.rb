class CreateWikiInformations < ActiveRecord::Migration
  def change
    create_table :wiki_informations do |t|
      t.string :name
      t.boolean :is_private, :default => false
      t.integer :created_by

      t.timestamps
    end
  end
end
