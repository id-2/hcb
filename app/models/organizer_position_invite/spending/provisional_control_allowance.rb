# == Schema Information
#
# Table name: organizer_position_invite_spending_provisional_control_allows
#
#  id                           :bigint           not null, primary key
#  amount_cents                 :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  organizer_position_invite_id :bigint
#
# Indexes
#
#  idx_on_organizer_position_invite_id_ba06d5295c  (organizer_position_invite_id)
#
class OrganizerPositionInvite
  module Spending
    class ProvisionalControlAllowance < ApplicationRecord
      self.table_name = "organizer_position_invite_spending_provisional_control_allows"

      belongs_to :organizer_position_invite
      monetize :amount_cents

      has_one :event, through: :organizer_position_invite

      validate :balance_is_positive, on: :create
      validate :one_provisional_control_allowance, on: :create

      private

      def balance_is_positive
        puts "sratoiarsntoeiarsnteisrt", amount_cents, "END"
        errors.add(:provisional_control_allowance, "balance must be positive") if amount_cents.negative?
      end

      def one_provisional_control_allowance
        if OrganizerPositionInvite::Spending::ProvisionalControlAllowance
             .where(organizer_position_invite_id: self.organizer_position_invite_id).exists?
          errors.add(:provisional_control_allowance, "must not be created on an organizer position invite with a provisional control allowance already present")
        end
      end

    end
  end

end
