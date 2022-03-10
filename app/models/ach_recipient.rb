# frozen_string_literal: true

class AchRecipient < ApplicationRecord
  has_paper_trail

  extend FriendlyId

  include PgSearch::Model
  pg_search_scope :search_name, against: [:recipient_name]

  belongs_to :event
  has_many :ach_transfers

  validates_presence_of :recipient_name, :routing_number, :account_number, :bank_name, :recipient_tel

end
