class AddUpdatedByToPages < ActiveRecord::Migration
  def change
    add_column :pages, :updated_by, :integer
    add_index :pages, :updated_by
  end
end
