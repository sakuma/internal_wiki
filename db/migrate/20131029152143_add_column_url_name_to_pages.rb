class AddColumnUrlNameToPages < ActiveRecord::Migration
  def change
    add_column :pages, :url_name, :string
  end
end
