# frozen_string_literal: true

module DisbursementJob
  class Daily < ApplicationJob
    def perform
      Disbursement.scheduled_for_today.find_each(batch_size: 100) do |disbursement|
        disbursement.mark_approved!(disbursement.fulfilled_by)
      end
    end

  end
end
