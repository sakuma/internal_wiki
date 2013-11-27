class CreateAttachments < ActiveRecord::Migration

  def change
    create_table :attachments do |t|
      t.references :page, index: true
      t.attachment :attachment
      t.timestamps
    end
  end
end
