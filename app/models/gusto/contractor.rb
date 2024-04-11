# == Schema Information
#
# Table name: gusto_contractors
#
#  id            :bigint           not null, primary key
#  gusto_object  :jsonb
#  gusto_version :string           not null
#  gusto_id      :string           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_gusto_contractors_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module Gusto
  class Contractor < ApplicationRecord
    belongs_to :user

    before_create :create_on_gusto

    private

    def create_on_gusto
      response = GustoService.post("/v1/companies/#{GustoService.company}/contractors", {
        type: "Individual",
        wage_type: "Fixed",
        self_onboarding: true,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        start_date: Date.today.strftime("%Y-%m-%d")
      })
      self.gusto_version = response["version"]
      self.gusto_id = response["uuid"]
      self.gusto_object = response
    end
    
  end
end
