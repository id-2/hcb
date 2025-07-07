# frozen_string_literal: true

class AnnouncementMailer < ApplicationMailer
  def announcement_published
    @announcement = params[:announcement]
    @event = @announcement.event
    @emails = @event.followers.map(&:email_address_with_name)
    
    mail to: @emails, subject: "#{@announcement.title} | #{@event.name}", from: hcb_email_with_name_of(@report.event)
  end

end
