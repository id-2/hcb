# frozen_string_literal: true

# == Schema Information
#
# Table name: reimbursements
#
#  id                :bigint           not null, primary key
#  aasm_state        :string
#  amount_cents      :integer
#  reimbursement_for :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  event_id          :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_reimbursements_on_event_id  (event_id)
#  index_reimbursements_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Reimbursement < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :event
  has_one_attached :receipt

  monetize :amount_cents

  aasm do
    state :pending_approval, initial: true
    state :approved
    state :rejected

    event :approve do
      transitions from: :pending_approval, to: :approved
    end

    event :reject do
      transitions from: :pending_approval, to: :rejected
    end
  end

  def state
    return :info if pending_approval?
    return :success if approved?
    return :error if rejected?

    :muted
  end

  def state_text
    return "Pending approval" if pending_approval?
    return "Approved" if approved?
    return "Rejected" if rejected?

    "???"
  end

end
