# frozen_string_literal: true

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
  scope :pending, -> { where(aasm_state: "pending") }
  scope :running, -> { where(aasm_state: "running") }
  scope :succeeded, -> { where(aasm_state: "succeeded") }
  scope :failure, -> { where(aasm_state: "failed") }
  scope :sleeping, -> { where(aasm_state: "sleeping") }

  has_many_attached :csv_files, dependent: :destroy
  has_one_attached :error_log, dependent: :destroy

  belongs_to :creator, class_name: "User", optional: true

  def run!
    self.aasm_state = "running"
    self.save!
    RollingBalanceReportJob.perform_later(self)
  end

  def succeed!
    self.aasm_state = "succeeded"
    self.save!
    RollingBalanceReportMailer.with(rolling_balance_report: self).success.deliver_later
  end

  def failure!
    self.aasm_state = "failed"
    self.save!
    RollingBalanceReportMailer.with(rolling_balance_report: self).failure.deliver_later
  end

  def sleep!
    self.aasm_state = "sleeping"
    self.save!
  end

end
