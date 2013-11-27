class AddAttachmentToPages < ActiveRecord::Migration
  def self.up
    change_table :pages do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :pages, :attachment
  end
end
