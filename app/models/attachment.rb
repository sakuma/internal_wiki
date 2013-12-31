class Attachment < ActiveRecord::Base
  belongs_to :page

  has_attached_file :attachment,
    storage: :s3,
    s3_credentials: "#{Rails.root}/config/s3.yml",
    s3_permissions: :private,
    path: "#{Settings.data_dir.attachments}/:id/:style/:filename"

  # TODO: バリデーション
end
