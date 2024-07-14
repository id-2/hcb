# == Schema Information
#
# Table name: wire_transfers
#
#  id                        :bigint           not null, primary key
#  account_number_ciphertext :text
#  amount_cents              :integer
#  approved_at               :datetime
#  bank_name                 :string
#  bic_number                :string
#  currency_code             :string
#  payment_for               :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  column_id                 :text
#  creator_id                :bigint
#  event_id                  :bigint
#  payment_recipient_id      :bigint
#
# Indexes
#
#  index_wire_transfers_on_creator_id            (creator_id)
#  index_wire_transfers_on_event_id              (event_id)
#  index_wire_transfers_on_payment_recipient_id  (payment_recipient_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (event_id => events.id)
#
class WireTransfer < ApplicationRecord
  has_paper_trail skip: [ # ciphertext columns will still be tracked
    :account_number,
    :recipient_address_city,
    :recipient_address_country_code,
    :recipient_address_line1,
    :recipient_address_line2,
    :recipient_address_postal_code,
    :recipient_email,
    :recipient_legal_id,
    :recipient_legal_type,
    :recipient_local_account_number,
    :recipient_local_bank_code,
    :recipient_name,
    :recipient_phone,
  ]

  has_encrypted :account_number
  has_encrypted :recipient_address_city
  has_encrypted :recipient_address_country_code
  has_encrypted :recipient_address_line1
  has_encrypted :recipient_address_line2
  has_encrypted :recipient_address_postal_code
  has_encrypted :recipient_email
  has_encrypted :recipient_legal_id
  has_encrypted :recipient_legal_type
  has_encrypted :recipient_local_account_number
  has_encrypted :recipient_local_bank_code
  has_encrypted :recipient_name
  has_encrypted :recipient_phone

  monetize :amount_cents

  include AASM

  belongs_to :creator, class_name: "User", optional: true
  belongs_to :processor, class_name: "User", optional: true
  belongs_to :event
  belongs_to :payment_recipient, optional: true

  validates :amount, numericality: { greater_than: 0, message: "must be greater than 0" }

  has_one :canonical_pending_transaction, through: :raw_pending_outgoing_ach_transaction

  # Eagerly create HcbCode object
  after_create :local_hcb_code

  def send_wire_transfer!
    # return unless may_mark_in_transit?
    # Create a counterparty
    counterparty = ColumnService.post("/counterparties", {
      routing_number: bic_number,
      routing_number_type: "bic",
      account_number:,
      name: recipient_name,
      "address[line_1]": recipient_address_line1,
      "address[line_2]": recipient_address_line2,
      "address[city]": recipient_address_city,
      "address[postal_code]": recipient_address_postal_code,
      "address[country_code]": recipient_address_country_code,
      phone: recipient_phone,
      email: recipient_email,
      legal_id: recipient_legal_id,
      legal_type: recipient_legal_type,
      local_bank_code: recipient_local_bank_code,
      local_account_number: recipient_local_account_number
    }.compact_blank)
    counterparty_id = counterparty["id"]

    account_number_id = event.column_account_number&.column_id ||
                        Rails.application.credentials.dig(:column, ColumnService::ENVIRONMENT, :default_account_number)

    # Initiate the wire
    column_wire_transfer = ColumnService.post("/transfers/wire", {
      description: payment_for,
      amount:,
      currency_code: "USD",
      account_number_id:,
      counterparty_id:,
    }.compact_blank)

    mark_in_transit
    self.column_id = column_wire_transfer["id"]

    save!
  end

  def hcb_code
    "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::WIRE_TRANSFER_CODE}-#{id}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code:)
  end
end
