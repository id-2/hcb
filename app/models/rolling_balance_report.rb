# == Schema Information
#
# Table name: rolling_balance_reports
#
#  id                  :bigint           not null, primary key
#  aasm_state          :string
#  job_runtime_seconds :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :bigint
#
# Indexes
#
#  index_rolling_balance_reports_on_creator_id  (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
class RollingBalanceReport < ApplicationRecord
  has_one_attached :csv_file, dependent: :destroy
  has_one_attached :error_log, dependent: :destroy

  belongs_to :creator, class_name: "User"

  include AASM
  aasm whiny_transitions: true do
    state :pending, initial: true
    state :running
    state :succeeded
    state :failed
    state :sleep

    event :run do
      transitions from: :pending, to: :running

      after do
        RollingBalanceReportJob.perform_later(self)
      end
    end

    event :succeed do
      transitions from: :running, to: :succeeded

      after do
        RollingBalanceReportMailer.with(rolling_balance_report: self).success.deliver_later
      end
    end

    event :failure do
      transitions from: [:running, :succeeded], to: :failed

      after do
        RollingBalanceReportMailer.with(rolling_balance_report: self).failure.deliver_later
      end
    end

    event :sleep do
      transitions from: [:succeeded, :failed], to: :sleep
    end
  end
end
