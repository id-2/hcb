# frozen_string_literal: true

module ReceiptService
  class Extract
    def initialize(receipt:)
      @receipt = receipt.reload
    end

    def run!
      @textual_content = @receipt.textual_content || @receipt.extract_textual_content!
      return nil if @textual_content.nil?

      conn = Faraday.new(
        url: "https://api.openai.com",
        headers: {
          "Content-Type"  => "application/json",
          "Authorization" => "Bearer #{Rails.application.credentials.openai.api_key}",
          "OpenAI-Beta"   => "assistants=v1"
        }
      )

      prompt = <<~PROMPT
        You are a helpful assistant that extracts important features from receipts. You must extract the following features in JSON format:

        amount_cents_subtotal
        amount_cents_total // the amount likely to be charged to a credit card
        card_last_four
        date // in the format of YYYY-MM-DD
        merchant_url // URL for merchant's primary website, if available
        merchant_name // without identifiers or oder numbers
        transaction_memo // a good memo includes quantity (if it's more than one), the item(s) purchased, and the merchant. pretend someone will use the memos in the sentence, "In this transaction, I purchased (a) <memo>" where <memo> is what you generate. some good examples are "🏷️ 5,000 Event stickers from StickerMule", "💧 Office water supply from Culligan", "🔌 USB-C cable for MacBook", "💾 10 Airtable team seats for December", and "🚕 Uber to SFO Airport". avoid generic quantifiers like "multiple" and "many", using improper capitalization, unnecessarily verbose descriptions, addresses, and transaction/merchant/order IDs. Ensure memos are less than 60 characters.
      PROMPT

      response = conn.post("/v1/chat/completions") do |req|
        req.body = {
          model: "gpt-4",
          messages: [
            {
              role: "system",
              content: prompt
            },
            {
              role: "user",
              content: @textual_content
            }
          ]
        }.to_json
      end

      JSON.parse(
        JSON.parse(response.body).dig("choices", 0, "message", "content")
      ).with_indifferent_access
    end

  end
end
