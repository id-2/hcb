# == Schema Information
#
# Table name: contractor_positions
#
#  id                  :bigint           not null, primary key
#  event_id            :bigint           not null
#  gusto_contractor_id :bigint           not null
#
# Indexes
#
#  index_contractor_positions_on_event_id             (event_id)
#  index_contractor_positions_on_gusto_contractor_id  (gusto_contractor_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (gusto_contractor_id => gusto_contractors.id)
#
class ContractorPosition < ApplicationRecord
  belongs_to :gusto_contractor, class_name: "Gusto::Contractor"
  belongs_to :event
end
