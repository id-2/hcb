# frozen_string_literal: true

class AchRecipient < ApplicationRecord
  has_paper_trail

  belongs_to :event

  has_many :ach_transfers, inverse_of: :beneficiary
  has_many :ach_accounts, inverse_of: :beneficiary

end
