# frozen_string_literal: true

class SlashZ < ApplicationRecord
  include AASM

  belongs_to :event
  belongs_to :user

  aasm do
    # Slash Z's API (https://github.com/hackclub/slash-z) will provide a meeting
    # status of 'OPEN' or 'ENDED'
    state :open, initial: true
    state :ended

    event :mark_ended do
      transitions from: :open, to: :ended
    end
  end
end
