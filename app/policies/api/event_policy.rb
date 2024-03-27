# frozen_string_literal: true

module Api
  class EventPolicy < ApplicationPolicy
    get(:event) { record }

    policy_for(
      :show?,
      :transactions?,
      :donations?,
      :transfers?,
      :invoices?,
      :ach_transfers?,
      :checks?,
      :card_charges?,
      :cards?
    ) { 🔎 }

  end
end
