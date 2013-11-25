class AddColumnUpdatedByToWikiInformations < ActiveRecord::Migration
  def change
    add_column :wiki_informations, :updated_by, :integer
    add_index :wiki_informations, :updated_by
    add_index :wiki_informations, :created_by
  end
end
