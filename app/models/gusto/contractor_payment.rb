# == Schema Information
#
# Table name: gusto_contractor_payments
#
#  id                     :bigint           not null, primary key
#  amount_cents           :integer          not null
#  gusto_object           :jsonb
#  gusto_version          :string           not null
#  contractor_position_id :bigint           not null
#  gusto_id               :string           not null
#
# Indexes
#
#  index_gusto_contractor_payments_on_contractor_position_id  (contractor_position_id)
#
# Foreign Keys
#
#  fk_rails_...  (contractor_position_id => contractor_positions.id)
#
module Gusto
  class ContractorPayment < ApplicationRecord
    belongs_to :contractor_position
    
    before_create :create_on_gusto
    
    private
    
    def create_on_gusto
      response = GustoService.post("/v1/companies/#{GustoService.company}/contractor_payments", {
        contractor_uuid: contractor_position.gusto_contractor.gusto_id,
        wage: amount_cents / 100,
        date: 2.weeks.from_now.strftime("%Y-%m-%d")
      })
      puts ({ contractor_uuid: contractor_position.gusto_contractor.gusto_id, wage: amount_cents / 100, date: Date.today.strftime("%Y-%m-%d") })
      self.gusto_version = "NA"
      self.gusto_id = response["uuid"]
      self.gusto_object = response
    end
    
  end
end
