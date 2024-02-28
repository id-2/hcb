# frozen_string_literal: true

# == Schema Information
#
# Table name: user_payout_method_ach_transfers
#
#  id                        :bigint           not null, primary key
#  account_number_ciphertext :text
#  routing_number_ciphertext :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
module User
  module PayoutMethod
    class AchTransfer < ApplicationRecord
      has_one :user, as: :payment_method
      has_encrypted :account_number, :routing_number
      validates :routing_number, format: { with: /\A\d{9}\z/, message: "must be 9 digits" }
      validates :account_number, format: { with: /\A\d+\z/, message: "must be only numbers" }

    end
  end
end
