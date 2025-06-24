# frozen_string_literal: true

module OneTimeJobs
  class BackfillTagEmojis
    def self.perform
      file = File.read "app/jobs/one_time_jobs/all-transaction-tags.csv"

      content = file[1..].split("\n").map { |line| line.split(",") }

      emojis = {}

      new_content = content.map do |line|
        label = line[1]

        emoji = ""

        if emojis.key? label
          emoji = emojis[label]
        else
          done = false
          new_label_clusters = label.grapheme_clusters.reject do |cluster|
            if done
              false
            else
              emoji_present = (/\p{Emoji}(?<!\d)/ =~ cluster).present?
              if emoji_present
                emoji = cluster
                Rails.logger.info "Found tag #{line[0]} (#{label}) - #{emoji}"
                done = true
              end

              emoji_present
            end
          end

          if !emoji.empty?
            label = new_label_clusters.join
          else
            conn = Faraday.new url: "https://api.openai.com" do |f|
              f.request :json
              f.request :authorization, "Bearer", -> { Credentials.fetch(:OPENAI_API_KEY) }
              f.response :raise_error
              f.response :json
            end

            response = conn.post("/v1/chat/completions", {
                                   model: "gpt-4o",
                                   messages: [
                                     {
                                       role: "system",
                                       content: "You are a helpful assistant that finds a single emoji to match a tag that is used on bank transactions. Reply only with a single emoji to match the tag label provided by the user."
                                     },
                                     {
                                       role: "user",
                                       content: label
                                     }
                                   ]
                                 })

            ai_response = response.body.dig("choices", 0, "message", "content")
            clusters = ai_response.grapheme_clusters
            Rails.logger.info "AI matched tag #{line[0]} (#{label}) - #{ai_response}"
            if clusters.size > 1 || (/\p{Emoji}(?<!\d)/ =~ clusters[0]).nil?
              Rails.logger.info "Invalid response from AI"
            else
              emoji = ai_response
            end
          end
        end

        emojis[label] = emoji

        line[6] = emoji
        line[1] = label.strip
        line
      end

      new_csv = new_content.map { |line| line.join(",") }.join("\n")

      File.write "new_tags.csv", new_csv
    end

  end
end
