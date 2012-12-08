class AddColumnWikiInformationIdToPages < ActiveRecord::Migration
  def change
    add_column :pages, :wiki_information_id, :integer
    add_index :pages, :wiki_information_id
  end
end
