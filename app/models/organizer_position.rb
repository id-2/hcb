# frozen_string_literal: true

# == Schema Information
#
# Table name: organizer_positions
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  first_time :boolean          default(TRUE)
#  is_signee  :boolean
#  sort_index :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_organizer_positions_on_event_id  (event_id)
#  index_organizer_positions_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (user_id => users.id)
#
class OrganizerPosition < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  scope :not_hidden, -> { where(event: { hidden_at: nil }) }

  belongs_to :user
  belongs_to :event

  has_one :organizer_position_invite
  has_many :organizer_position_deletion_requests
  has_many :tours, as: :tourable

  validates :user, uniqueness: { scope: :event, conditions: -> { where(deleted_at: nil) } }

  def initial?
    organizer_position_invite.initial?
  end

  def tourable_options
    {
      demo: event.demo_mode?,
      category: event.category,
      initial: initial?
    }
  end

  def signee?
    is_signee
  end

  def spent
    card = event.canonical_transactions.stripe_transaction.joins("JOIN stripe_cardholders on raw_stripe_transactions.stripe_transaction->>'cardholder' = stripe_cardholders.stripe_id").where(stripe_cardholders: { user_id: user.id }).sum(:amount_cents) + event.emburse_transactions.joins("JOIN emburse_cards on emburse_transactions.emburse_card_id = emburse_cards.id").where(emburse_cards: { user_id: user.id }).sum(:amount)
    ach = event.ach_transfers.where(creator_id: user.id, rejected_at: nil).sum(:amount)
    checks = event.checks.where(creator_id: user.id, rejected_at: nil).sum(:amount) + event.increase_checks.where(user_id: user.id, increase_status: "deposited").where.not(approved_at: nil).sum(:amount)
    disbursements = event.disbursements.where(requested_by_id: user.id).where.not(fulfilled_by_id: nil).sum(:amount)
    card + ach + disbursements
  end

end
