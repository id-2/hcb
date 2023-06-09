# frozen_string_literal: true

# == Schema Information
#
# Table name: suggested_pairings
#
#  distance    :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  hcb_code_id :bigint           not null
#  receipt_id  :bigint           not null
#
class SuggestedPairing < ApplicationRecord
  belongs_to :receipt
  belongs_to :hcb_code

  # has a column for `distance`
end


