# == Schema Information
#
# Table name: organizer_position_spending_controls
#
#  id                    :bigint           not null, primary key
#  active                :boolean
#  ended_at              :datetime
#  started_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  organizer_position_id :bigint           not null
#
# Indexes
#
#  idx_org_pos_spend_ctrls_on_org_pos_id  (organizer_position_id)
#
# Foreign Keys
#
#  fk_rails_...  (organizer_position_id => organizer_positions.id)
#
class OrganizerPosition::Spending::Control < ApplicationRecord
  belongs_to :organizer_position
  has_many :allowances

  scope :active_spending_control, -> { where(active: true) }

  validate :one_active_control

  def one_active_control
    if organizer_position.spending_controls.where(active: true).size > 1
      errors.add(:organizer_position, "may only have one active spending control")
    end
  end

end
