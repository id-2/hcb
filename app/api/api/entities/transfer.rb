# frozen_string_literal: true

module Api
  module Entities
    class Transfer < LinkedObjectBase
      when_expanded do
        expose :amount, as: :amount_cents
        expose :created_at, as: :date
        expose :v3_api_state, as: :status, documentation: {
          values: %w[
            fulfilled
            processing
            rejected
            errored
            under_review
            pending
          ]
        }

        for_version(:>=, 'v3.1.0.0') do
          unexpose :organization # inherited from LinkedObjectBase

          expose_associated Organization, as: "source_organization", hide: [API_LINKED_OBJECT_TYPE, Transaction, User] do |disbursement, options|
            disbursement.source_event
          end

          expose_associated Organization, as: "destination_organization", hide: [API_LINKED_OBJECT_TYPE, Transaction, User] do |disbursement, options|
            disbursement.destination_event
          end
        end

      end

    end
  end
end
