# frozen_string_literal: true

# == Schema Information
#
# Table name: reimbursement_expenses
#
#  id                        :bigint           not null, primary key
#  aasm_state                :string
#  amount_cents              :integer          default(0), not null
#  approved_at               :datetime
#  description               :text
#  memo                      :text
#  reimbursable_amount_cents :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  approved_by_id            :bigint
#  reimbursement_report_id   :bigint           not null
#
# Indexes
#
#  index_reimbursement_expenses_on_approved_by_id           (approved_by_id)
#  index_reimbursement_expenses_on_reimbursement_report_id  (reimbursement_report_id)
#
# Foreign Keys
#
#  fk_rails_...  (approved_by_id => users.id)
#  fk_rails_...  (reimbursement_report_id => reimbursement_reports.id)
#
module Reimbursement
  class Expense < ApplicationRecord
    belongs_to :report, inverse_of: :expenses, foreign_key: "reimbursement_report_id"
    monetize :amount_cents, as: "amount"
    include AASM
    include Receiptable

    include Hashid::Rails
    hashid_config min_hash_length: 3

    aasm do
      state :pending, initial: true
      state :approved

      event :mark_approved do
        transitions from: :pending, to: :approved
      end

      event :mark_pending do
        transitions from: :approved, to: :pending
      end
    end

    def event
      self.report.event
    end

    def receipt_required?
      true
    end

    def marked_no_or_lost_receipt_at
      nil
    end

    def missing_receipt?
      true
    end

    def rejected?
      pending? && report.closed?
    end

    delegate :locked?, to: :report

    def status_color
      return "primary" if report.rejected? || rejected?
      return "warning" if pending?

      "success"
    end

  end
end
