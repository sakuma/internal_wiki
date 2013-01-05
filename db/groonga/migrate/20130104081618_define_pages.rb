class DefinePages < ActiveGroonga::Migration
  def up
    create_table("pages", :type => :hash, :key_type => "ShortText") do |table|
      table.text("body")
    end
  end

  def down
    remove_table("pages")
  end
end
