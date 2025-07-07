# frozen_string_literal: true

class AnnouncementPublishedJob < ApplicationJob
  queue_as :default
  def perform(announcement:)
    emails = announcement.event.followers.map(&:email_address_with_name)

    emails.each do |email|
      AnnouncementMailer.with(announcement:, email:).announcement_published.deliver_later
    end
  end

end
