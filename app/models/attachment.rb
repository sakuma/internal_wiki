class Attachment < ActiveRecord::Base
  belongs_to :page

  has_attached_file :attachment,
    path: "#{Settings.data_dir.attachments}/:id/:style/:filename"

  # TODO: バリデーション
end
