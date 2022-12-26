# frozen_string_literal: true

class TwilioController < ApplicationController
  include ActionView::Helpers::TextHelper # for `pluralize`

  protect_from_forgery except: :webhook # ignore csrf checks
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user # do not require logged in user
  before_action :set_attachments, :set_user

  def webhook
    twilio_message = TwilioMessage.new(
      to: params['To'],
      from: params['From'],
      body: params['Body'],
      twilio_sid: params['MessageSid'],
      twilio_account_sid: params['AccountSid'],
      raw_data: request.params.to_h,
      hcb_code: last_sent_message_hcb_code,
      direction: :incoming
    )

    response_msg = ""
    # rubocop:disable Naming/VariableNumber
    if @user.present? && Flipper.enabled?(:sms_receipt_notifications_2022_11_23, @user)
    # rubocop:enable Naming/VariableNumber

      # This is a user & they're opted into the beta, continue forward

      if @attachments.none?
        response_msg = "No attached files found!"

      else
        response_msg = "Added #{pluralize @attachments.count, 'receipt'}!"
        grab_attachments!

        @attachments.each do |attachment|
          twilio_message.files.attach(
            io: attachment[:io],
            filename: attachment[:filename],
            content_type: attachment[:content_type]
          )

          attachable = ActiveStorage::Blob.create_and_upload!(
            io: attachment[:io],
            filename: attachment[:filename],
            content_type: attachment[:content_type]
          )

          ::HcbCodeService::Receipt::Create.new(
            hcb_code_id: last_sent_message_hcb_code.id,
            file: attachable,
            upload_method: :sms,
            current_user: @user
          ).run
        end
      end

    end

    begin
      twilio_message.save!
    rescue ActiveStorage::IntegrityError => e
      # This error is thrown in development– still need to debug this
    end

    respond_to do |format|
      format.xml { render xml: "<Response><Message>#{response_msg}</Message></Response>" }
    end
  end

  private

  def set_user
    @user ||= begin
      potential_users = User.where(phone_number: params['From'])
      return potential_users.first if potential_users.count == 1

      # If we have multiple users with the same phone number, try to find the user via their stripe card
      user_id = last_sent_message_hcb_code&.canonical_pending_transactions&.last&.stripe_card&.user&.id
      potential_users.find_by(id: user_id)
    end
  end

  def set_attachments
    @attachments ||= begin
      results = []

      num_media = params['NumMedia'].to_i

      unless num_media.zero?
        (0..num_media - 1).each do |i|
          attachment = {}
          attachment[:media_url] = params["MediaUrl#{i}"]
          attachment[:filename] = File.basename(URI.parse(attachment[:media_url]).path)
          attachment[:content_type] = params["MediaContentType#{i}"]
          results << attachment
        end
      end

      results
    end
  end

  def grab_attachments!
    @attachments.each do |attachment|
      url = URI.parse(attachment[:media_url])
      attachment[:io] = URI.parse(url).open
    end
  end

  def last_sent_message_hcb_code
    @last_sent_message_hcb_code ||= TwilioMessage.outgoing
                                                 .where(to: params["From"])
                                                 .where.not(hcb_code: nil)
                                                 .last&.hcb_code
  end

end
