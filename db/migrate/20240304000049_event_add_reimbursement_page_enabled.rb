class EventAddReimbursementPageEnabled < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :self_service_reimbursement_page_enabled, :boolean, default: false
  end
end
