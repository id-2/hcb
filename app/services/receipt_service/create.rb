# frozen_string_literal: true

module ReceiptService
  class Create
    def initialize(attachments:, uploader:, upload_method: nil, receiptable: nil)
      @attachments = attachments
      @receiptable = receiptable
      @uploader = uploader
      @upload_method = upload_method
    end

    def run!
      suppress(ActiveModel::MissingAttributeError) do
        @receiptable&.update(marked_no_or_lost_receipt_at: nil)
      end

      ActiveRecord::Base.transaction do
        @attachments.map do |attachment|
          receipt = Receipt.create!(attrs(attachment))

          pairings = ::ReceiptService::Suggest.new(receipt: receipt).run!

          unless pairings.nil?
            pairs = pairings.map do |pairing|
              {
                receipt: receipt,
                hcb_code: pairing[:hcb_code],
                distance: pairing[:distance]
              }
            end
            SuggestedPairing.insert_all(pairs)
          end

          receipt
        end
      end
    end

    private

    def attrs(attachment)
      {
        file: attachment,
        uploader: @uploader,
        upload_method: @upload_method,
        receiptable: @receiptable   # Receiptable may be nil
      }
    end

  end
end
