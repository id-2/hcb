# == Schema Information
#
# Table name: organizer_position_spending_authorizations
#
#  id                    :bigint           not null, primary key
#  amount_cents          :integer          not null
#  memo                  :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  authorized_by_id      :bigint           not null
#  organizer_position_id :bigint           not null
#
# Indexes
#
#  idx_org_pos_spend_auths_on_authed_by_id  (authorized_by_id)
#  idx_org_pos_spend_auths_on_org_pos_id    (organizer_position_id)
#
# Foreign Keys
#
#  fk_rails_...  (authorized_by_id => users.id)
#  fk_rails_...  (organizer_position_id => organizer_positions.id)
#
module OrganizerPosition::Spending
  class Authorization < ApplicationRecord
    belongs_to :organizer_position

    def total_spent
    end

    def total_allocated
    end

    def balance
    end

    def organizer_position
      OrganizerPosition.find(organizer_position_id)
    end

    def authorized_by
      OrganizerPosition.find(authorized_by_id)
    end
  end
  
  def self.table_name_prefix
    "organizer_position_spending_"
  end

end
