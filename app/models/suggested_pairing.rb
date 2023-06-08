class SuggestedPairing < ApplicationRecord
  belongs_to :receipt
  belongs_to :hcb_code

  # has a column for `distance`
end





