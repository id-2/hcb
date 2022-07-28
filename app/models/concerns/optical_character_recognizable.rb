# frozen_string_literal: true

module OpticalCharacterRecognizable
  extend ActiveSupport::Concern

  included do
    has_one :ocr, as: :document

    class_attribute :attachment_for_ocr
    before_create :generate_ocr
  end

  def generate_ocr
    raise NotImplementedError, "#{self.class.name} model does not have `ocr_on` set, but includes and uses OpticalCharacterRecognizable" if self.class.ocr_on.nil?
    return ocr if ocr.present?

    # TODO: process pdf/image.
    # If PDF, convert to hi-res image.
    # Make image black and white (improve contrast)
    newly_uploaded = self.attachment_changes[self.class.ocr_on.to_s]&.attachable.present?
    file = if newly_uploaded
             self.attachment_changes[self.class.ocr_on.to_s]&.attachable
           else
             self.send(self.class.ocr_on)
           end

    if newly_uploaded
      run_and_create_ocr(filepath: file.path, filename: file.original_filename)
    else
      # Existing file (already uploaded/saved)
      file.blob.open do |f|
        run_and_create_ocr(filepath: f.path, filename: file.filename)
      end
    end
  rescue => e
    # Mainly just image files can be OCR'ed. Others will fail
    ap e if Rails.env.development?
  end

  class_methods do
    def ocr_on(file = nil)
      if file.nil?
        raise NotImplementedError, "#{self.class.name} model does not have `ocr_on` set, but includes and uses OpticalCharacterRecognizable" if self.attachment_for_ocr.nil?
        return attachment_for_ocr
      end

      self.attachment_for_ocr = file
    end
  end

  private

  def run_and_create_ocr(filepath:, filename:)
    t = RTesseract.new(filepath)
    self.build_ocr(text: t.to_s)
        .pdf.attach(io: t.to_pdf, filename: filename)
  end

end
