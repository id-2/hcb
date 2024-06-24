class CreateOrganizerPositionInviteSpendingProvisionalControlAllowances < ActiveRecord::Migration[7.1]
  def change
    create_table :organizer_position_invite_spending_provisional_control_allows do |t| # The table name was too long
      t.belongs_to :organizer_position_invite
      t.integer :amount_cents

      t.timestamps
    end
  end

end
