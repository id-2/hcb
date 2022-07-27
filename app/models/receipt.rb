# frozen_string_literal: true

# == Schema Information
#
# Table name: receipts
#
#  id                 :bigint           not null, primary key
#  attempted_match_at :datetime
#  receiptable_type   :string
#  upload_method      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  receiptable_id     :bigint
#  user_id            :bigint
#
# Indexes
#
#  index_receipts_on_receiptable_type_and_receiptable_id  (receiptable_type,receiptable_id)
#  index_receipts_on_user_id                              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Receipt < ApplicationRecord
  belongs_to :receiptable, polymorphic: true
  has_one :ocr, as: :document

  belongs_to :user, class_name: "User", required: false
  alias_attribute :uploader, :user
  alias_attribute :transaction, :receiptable

  has_one_attached :file

  validates :file, attached: true

  after_create :generate_ocr

  enum upload_method: {
    transaction_page: 0,
    transaction_page_drag_and_drop: 1,
    receipts_page: 2,
    receipts_page_drag_and_drop: 3,
    attach_receipt_page: 4,
    attach_receipt_page_drag_and_drop: 5,
    email: 6
  }

  def filename
    file.blob.filename
  end

  def url
    Rails.application.routes.url_helpers.rails_blob_url file
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

  # TODO: move this
  def generate_ocr
    return ocr if ocr.present?

    # TODO: process pdf/image.
    # If PDF, convert to hi-res image.
    # Make image black and white (improve contrast)

    if (file = self.attachment_changes['file']&.attachable)
      # Newly uploaded file. It hasn't been saved
      run_and_create_ocr(filepath: file.path, filename: file.original_filename)
    else
      # Existing file (already uploaded/saved)
      self.file.blob.open do |f|
        run_and_create_ocr(filepath: f.path, filename: self.file.filename)
      end
    end
    # rescue => e
    #   ap e
    #   Airbrake.notify e
  end

  private

  def run_and_create_ocr(filepath:, filename:)
    t = RTesseract.new(filepath)
    Ocr.new.tap do |ocr|
      ocr.document = self
      ocr.text = t.to_s
      ocr.pdf.attach(io: t.to_pdf, filename: filename)
    end.save!
  end

end
