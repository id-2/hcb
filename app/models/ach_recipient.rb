# frozen_string_literal: true

class AchRecipient < ApplicationRecord
  has_paper_trail

  belongs_to :ach_account
  belongs_to :event

  has_many :ach_transfers, as: :beneficiary

end
