# frozen_string_literal: true

module OneTimeJobs
  class ZachTeenagers < ApplicationJob
    def perform
      csv_file = Rails.root.join("hcb_teenagers_#{timestamp}.csv")
      File.write(csv_file, csv)
    end

    def csv
      CSV.generate do |csv|
        csv << headers

        teenagers.each do |user|
          csv << [
            user.first_name(legal: true),
            user.last_name(legal: true),
            user.email,
            user.created_at,
            user.user_sessions.order(created_at: :desc).first&.created_at,
            user.birthday,
          ]
        end
      end
    end

    def headers
      %w[firstName lastName email hcbSignedUpAt hcbLastLoginAt birthday]
    end

    def timestamp
      Time.current.strftime("%b_%d_%Y").downcase
    end

    def teenagers
      Rails.logger.silence do
        teens_by_age = User.find_each.filter_map do |user|
          user if user.birthday&.after?(20.years.ago)
        end
        puts "Found #{teens_by_age.size} teenagers by age"

        teens_by_hackathon = User.includes(organizer_positions: :event).where(organizer_positions: { events: { category: 'high school hackathon' } })
        puts "Found #{teens_by_hackathon.size} teenagers by high school hackathon"

        users = (teens_by_age + teens_by_hackathon).uniq.sort_by(&:id)
        puts "Total: #{users.size} teenagers"
        users
      end
    end
  end
end
