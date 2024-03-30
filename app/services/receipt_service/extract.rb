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
        merchant_name // without identifiers or order numbers
        merchant_zip_code // if available
        transaction_memo // a good memo includes quantity (if it's more than one), the item(s) purchased, and the merchant. pretend someone will use the memos in the sentence, "In this transaction, I purchased (a) <memo>" where <memo> is what you generate. some good examples are "🏷️ 5,000 Event stickers from StickerMule", "💧 Office water supply from Culligan", "🔌 USB-C cable for MacBook", "💾 10 Airtable team seats for December", and "🚕 Uber to SFO Airport". avoid generic quantifiers like "multiple" and "many", using improper capitalization, unnecessarily verbose descriptions, addresses, and transaction/merchant/order IDs. Ensure memos are less than 60 characters.

        If you can't extract a feature, or if you can't find any features, return null for the respective keys.
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

      body = JSON.parse(response.body) # JSON returned by OpenAI API, unlikely to fail
      ai_response = body.dig("choices", 0, "message", "content")

      extracted = begin
        JSON.parse(ai_response).with_indifferent_access # JSON given by ChatGPT, may fail
      rescue JSON::ParserError
        nil
      end

      return if extracted.nil?

      extracted[:textual_content] = @receipt.textual_content

      data = OpenStruct.new(extracted) # Protection against missing keys

      @receipt.update(
        suggested_amount_cents_subtotal: data.amount_cents_subtotal&.to_i,
        suggested_amount_cents_total: data.amount_cents_total&.to_i,
        suggested_card_last4: data.card_last_four,
        suggested_date: data.date.to_date,
        suggested_memo: data.memo,
        suggested_merchant_name: data.merchant_name,
        suggested_merchant_url: data.merchant_url,
        suggested_merchant_zip_code: data.merchant_zip_code
      )

      data
    end

  end
end
