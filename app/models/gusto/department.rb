# == Schema Information
#
# Table name: gusto_departments
#
#  id            :bigint           not null, primary key
#  gusto_object  :jsonb
#  gusto_version :string           not null
#  event_id      :bigint           not null
#  gusto_id      :string           not null
#
# Indexes
#
#  index_gusto_departments_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
module Gusto
  class Department < ApplicationRecord
    belongs_to :event
    
    before_create :create_on_gusto
    
    private
    
    def create_on_gusto
      response = GustoService.post("/v1/companies/#{GustoService.company}/departments", { title: event.name })
      self.gusto_version = response["version"]
      self.gusto_id = response["uuid"]
      self.gusto_object = response
    end
  end
end
