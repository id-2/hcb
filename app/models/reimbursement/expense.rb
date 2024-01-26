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

    include AASM

    aasm do
      state :pending, initial: true
      state :approved

      event :mark_approved do
        transitions from: :pending, to: :approved
      end
    end

    def event
      self.report.event
    end

  end
end
