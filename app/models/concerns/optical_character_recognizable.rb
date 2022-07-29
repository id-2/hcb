# frozen_string_literal: true

module OpticalCharacterRecognizable
  extend ActiveSupport::Concern

  included do
    has_one :ocr, as: :document, dependent: :destroy

    class_attribute :attachment_for_ocr
    before_create :generate_ocr
  end

  def generate_ocr
    raise NotImplementedError, "#{self.class.name} model does not have `ocr_on` set, but includes and uses OpticalCharacterRecognizable" if self.class.ocr_on.nil?
    return ocr if ocr.present?

    generated_ocr = nil

    process = proc do |filename:, content_type: nil|
      # This block can be later passed into ActiveStorage::Blob#open to access
      # the tempfile before it's unlinked and closed.
      proc do |tempfile|
        OcrService::Preprocess.new(file: tempfile, filename: filename, content_type: content_type).run do |processed|
          generated_ocr = run_and_create_ocr(filepath: processed[:path], filename: processed[:filename])
        end
      end
    end

    newly_uploaded = self.attachment_changes[self.class.ocr_on.to_s]
    if newly_uploaded
      file = self.attachment_changes[self.class.ocr_on.to_s].attachable
      filename = file.original_filename
      process.call(filename: filename, content_type: file.content_type).call(file)
    else
      file = self.send(self.class.ocr_on)
      filename = file.filename.to_s
      file.open(&process.call(filename: filename, content_type: file.content_type))
    end

    generated_ocr

    # rescue => e
    #   # Mainly just image files can be OCR'ed. Others will fail
    #   ap e if Rails.env.development?
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
    new_ocr = self.build_ocr(text: t.to_s)
    new_ocr.pdf.attach(io: t.to_pdf, filename: filename)

    new_ocr.save unless new_record?
    new_ocr
  end

end
