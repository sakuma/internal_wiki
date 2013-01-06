class DefinePages < ActiveGroonga::Migration
  def up
    create_table("pages", :type => :patricia_trie,
                 :key_type => "ShortText") do |table|
      table.uint64("page_id")
      table.uint64("wiki_information_id")
      table.text("body")
    end
  end

  def down
    remove_table("pages")
  end
end
