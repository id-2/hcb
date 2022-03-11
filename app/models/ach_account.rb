class AchAccount < ApplicationRecord
  encrypts :bank_name
  encrypts :routing_number
  encrypts :account_number

end
