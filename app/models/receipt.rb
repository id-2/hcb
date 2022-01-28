# frozen_string_literal: true

class Receipt < ApplicationRecord
  after_create_commit :convert_files
  belongs_to :receiptable, polymorphic: true

  belongs_to :user, class_name: "User", required: false
  alias_attribute :uploader, :user
  alias_attribute :transaction, :receiptable

  has_one_attached :file

  validates :file, attached: true

  def url
    Rails.application.routes.url_helpers.rails_blob_url(object)
  end

  def preview(resize: "512x512")
    if file.previewable?
      Rails.application.routes.url_helpers.rails_representation_url(file.preview(resize: resize).processed, only_path: true)
    elsif file.variable?
      Rails.application.routes.url_helpers.rails_representation_url(file.variant(resize: resize).processed, only_path: true)
    end
  rescue ActiveStorage::FileNotFoundError
    nil
  end

  def convert_files
    if self.file.content_type == 'image/heic'
      self.file.blob.open do |tempfile|
        old_file_name = File.basename(self.file.filename.to_s, File.extname(self.file.filename.to_s))
        image = MiniMagick::Image.new(tempfile.path)
        image.format "jpg"
        self.file.purge
        self.file.attach(io: File.open(image.path), filename: "#{old_file_name}.jpg", content_type: "image/jpg")
      end
    end
  end

end
