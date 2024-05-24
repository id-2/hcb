# == Schema Information
#
# Table name: organizer_position_spending_allowances
#
#  id                                     :bigint           not null, primary key
#  amount_cents                           :integer          not null
#  memo                                   :text
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  authorized_by_id                       :bigint           not null
#  organizer_position_spending_control_id :bigint           not null
#
# Indexes
#
#  idx_org_pos_spend_allows_on_authed_by_id           (authorized_by_id)
#  idx_org_pos_spend_allows_on_org_pos_spend_ctrl_id  (organizer_position_spending_control_id)
#
# Foreign Keys
#
#  fk_rails_...  (authorized_by_id => users.id)
#  fk_rails_...  (organizer_position_spending_control_id => organizer_position_spending_controls.id)
#
module OrganizerPosition::Spending
  class Allowance < ApplicationRecord
    belongs_to :organizer_position_spending_control, class_name: "OrganizerPosition::Spending::Control"
    belongs_to :authorized_by, class_name: "OrganizerPosition"
    monetize :amount_cents

    has_one :organizer_position, through: :organizer_position_spending_control

  end

  def self.table_name_prefix
    "organizer_position_spending_"
  end

end
