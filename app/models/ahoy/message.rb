# frozen_string_literal: true

# == Schema Information
#
# Table name: ahoy_messages
#
#  id        :bigint           not null, primary key
#  mailer    :string
#  sent_at   :datetime
#  subject   :text
#  to        :string
#  user_type :string
#  user_id   :bigint
#
# Indexes
#
#  index_ahoy_messages_on_to    (to)
#  index_ahoy_messages_on_user  (user_type,user_id)
#
module Ahoy
  class Message < ApplicationRecord
    self.table_name = "ahoy_messages"

    belongs_to :user, polymorphic: true, optional: true

  end
end
