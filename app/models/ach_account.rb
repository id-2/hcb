# frozen_string_literal: true

class AchAccount < ApplicationRecord
  has_paper_trail

  encrypts :bank_name
  encrypts :routing_number
  encrypts :account_number

end
