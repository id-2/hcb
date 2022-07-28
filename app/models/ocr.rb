# == Schema Information
#
# Table name: ocrs
#
#  id            :bigint           not null, primary key
#  document_type :string
#  text          :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  document_id   :bigint
#
# Indexes
#
#  index_ocrs_on_document  (document_type,document_id)
#
class Ocr < ApplicationRecord
  belongs_to :document, polymorphic: true

  has_one_attached :pdf
  validates :pdf, attached: true

  before_validation :clean_text

  def empty_text?
    text.blank?
  end

  def filename
    pdf.blob.filename
  end

  def url
    Rails.application.routes.url_helpers.rails_blob_url pdf
  end

  def preview(resize: "512x512")
    if pdf.previewable?
      Rails.application.routes.url_helpers.rails_representation_url(file.preview(resize: resize).processed, only_path: true)
    elsif pdf.variable?
      Rails.application.routes.url_helpers.rails_representation_url(file.variant(resize: resize).processed, only_path: true)
    end
  rescue ActiveStorage::FileNotFoundError
    nil
  end

  private

  def clean_text
    self.text = self.text.strip
  end

end
