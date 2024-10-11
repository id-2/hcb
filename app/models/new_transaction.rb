# == Schema Information
#
# Table name: new_transactions
#
#  id                      :bigint           not null, primary key
#  amount_cents            :integer
#  datetime                :datetime
#  memo                    :string
#  transaction_source_type :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  event_id                :bigint
#  transaction_source_id   :bigint
#
# Indexes
#
#  index_new_transactions_on_event_id            (event_id)
#  index_new_transactions_on_transaction_source  (transaction_source_type,transaction_source_id)
#
class NewTransaction < ApplicationRecord

  belongs_to :transaction_source, polymorphic: true, optional: true


  # date_time
  # amount_cents
  # memo
end
