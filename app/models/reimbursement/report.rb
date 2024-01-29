# frozen_string_literal: true

# == Schema Information
#
# Table name: reimbursement_reports
#
#  id                    :bigint           not null, primary key
#  aasm_state            :string
#  admin_approved_at     :datetime
#  invite_message        :text
#  maximum_amount_cents  :integer
#  name                  :text
#  organizer_approved_at :datetime
#  reimbursed_at         :datetime
#  rejected_at           :datetime
#  submitted_at          :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  event_id              :bigint           not null
#  invited_by_id         :bigint
#  user_id               :bigint           not null
#
# Indexes
#
#  index_reimbursement_reports_on_event_id       (event_id)
#  index_reimbursement_reports_on_invited_by_id  (invited_by_id)
#  index_reimbursement_reports_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
module Reimbursement
  class Report < ApplicationRecord
    belongs_to :user
    belongs_to :event

    has_paper_trail

    monetize :maximum_amount_cents, as: "maximum_amount"
    has_many :expenses, foreign_key: "reimbursement_report_id", inverse_of: :report
    alias_attribute :report_name, :name

    scope :search, ->(q) { joins(:user).where("users.full_name ILIKE :query OR reimbursement_reports.name ILIKE :query", query: "%#{User.sanitize_sql_like(q)}%") }

    include AASM
    include Commentable

    aasm do
      state :draft, initial: true
      state :submitted
      state :organizer_approved
      state :admin_approved
      state :rejected
      state :reimbursed

      event :mark_submitted do
        transitions from: [:draft, :organizer_approved], to: :submitted
      end

      event :mark_organizer_approved do
        transitions from: :submitted, to: :organizer_approved
      end

      event :mark_admin_approved do
        transitions from: :organizer_approved, to: :admin_approved
      end

      event :mark_rejected do
        transitions from: [:draft, :submitted, :organizer_approved], to: :rejected
      end

      event :mark_draft do
        transitions from: [:submitted], to: :draft
      end

      event :mark_reimbursed do
        transitions from: :admin_approved, to: :reimbursed
      end
    end

    def status_text
      return "Draft" if draft?

      aasm_state.humanize
    end

    def locked?
      !draft?
    end

    def unlockable?
      submitted? || organizer_approved?
    end

    def amount_cents
      expenses.sum(&:amount_cents)
    end

    def last_organizer_approved_by
      last_user_change_to(aasm_state: "organizer_approved")
    end

    def last_admin_approved_by
      last_user_change_to(aasm_state: "admin_approved")
    end

    def last_rejected_by
      last_user_change_to(aasm_state: "rejected")
    end

    def expenses_updated_at
      expenses.maximum(:updated_at)
    end

    def report_updated_at
      [updated_at, expenses_updated_at].max
    end

    private

    def last_user_change_to(**query)
      user_id = versions.where_object_changes_to(**query).last&.whodunnit

      user_id && User.find(user_id)
    end

  end
end
