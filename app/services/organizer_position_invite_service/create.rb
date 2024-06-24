# frozen_string_literal: true

module OrganizerPositionInviteService
  class Create
    def initialize(event:, sender: nil, user_email: nil, initial: false, is_signee: false, role: nil, enable_controls: nil, initial_control_amount: nil)
      @event = event
      @sender = sender
      @user_email = user_email
      @initial = initial
      @is_signee = is_signee
      @role = role
      @enable_controls = enable_controls
      puts("rasontnsrtnsr, ", enable_controls, @enable_controls)
      @initial_control_amount = initial_control_amount

      args = {}
      args[:event] = @event
      args[:sender] = @sender
      args[:initial] = @initial
      args[:is_signee] = @is_signee
      args[:role] = @role if role

      @model = OrganizerPositionInvite.new(args)
    end

    def run
      ActiveRecord::Base.transaction do
        find_or_create_user

        @model.save

        OrganizerPositionInvite::Spending::ProvisionalControlAllowance.create!({organizer_position_invite: @model, amount: @initial_controls_amount}) if @enable_controls
      end
    rescue ActiveRecord::RecordInvalid => e
      @model.errors.add(:base, message: e.message)
      false # signal that we didn't save the model properly
    end

    def run!
      ActiveRecord::Base.transaction do
        find_or_create_user

        @model.save!
      end
    end

    # This isn't ideal, but expose the model directly for dealing with errors or forms
    def model
      @model
    end

    private

    def find_or_create_user
      # Create the invited user now if it doesn't exist
      @model.user = User.find_or_create_by!(email: @user_email)
    end

  end
end
