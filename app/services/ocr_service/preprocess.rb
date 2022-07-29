# frozen_string_literal: true

module OcrService
  class Preprocess
    # https://github.com/tesseract-ocr/tessdoc/blob/main/InputFormats.md
    TESSERACT_SUPPORTED_FORMATS = %w(image/pdf image/jpeg image/jpg image/gif image/webp image/bmp image/pnm)
    IMAGE_FORMAT = 'tiff' # people report that TIFF is the best format, however, i've been seeing better results with PNG

    # @param [ActiveStorage::Attached::One, ActionDispatch::Http::UploadedFile] file
    def initialize(file:, filename:, content_type: nil)
      @file = file
      @filename = filename
      @content_type = content_type
      @process = []
    end

    # Using a block will help ensure the tempfile gets unlinked
    def run(&block)
      @process << to_image(@file)
      # TODO: additional processing

      # Unlink tempfiles (all but last)
      @process[0...-1].each { |p| p.try(:unlink) }

      output = @process.last
      ret = {
        path: output.path,
        filename: "#{@filename}.#{IMAGE_FORMAT}"
      }

      return ret unless block

      block.call ret
      output.try(:unlink) # unlink last tempfile
    end

    private

    def to_image(file)
      return file if TESSERACT_SUPPORTED_FORMATS.include? @content_type # file is already an image

      tempfile = Tempfile.new # should be unlinked later
      MiniMagick::Image
        .open(file.path)
        .format(IMAGE_FORMAT)
        .density('700')
        # .alpha('off')
        # .theshold('50%')
        # .grayscale
        # .fill('white')
        # .fuzz('30%')
        # .opaque.+('30%')
        .write(tempfile.path)

      tempfile
    end

  end
end
