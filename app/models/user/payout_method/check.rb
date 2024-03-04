# frozen_string_literal: true

# == Schema Information
#
# Table name: user_payout_method_checks
#
#  id                  :bigint           not null, primary key
#  address_city        :text
#  address_country     :text
#  address_line1       :text
#  address_line2       :text
#  address_postal_code :text
#  address_state       :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class User
  module PayoutMethod
    class Check < ApplicationRecord
      # this is here because otherwise the annotate gem would ignore namespaces and annotate this model as if it were the Check model.
      self.table_name = "user_payout_method_checks"
      has_one :user, as: :payment_method
      validates_presence_of :address_line1, :address_city, :address_postal_code
      validates_presence_of :address_state, message: "Please select a state!"
      validates :address_state, inclusion: { in: ISO3166::Country["US"].states.keys, message: "This isn't a valid US state!", allow_blank: true }
      validates :address_postal_code, format: { with: /\A\d{5}(?:[-\s]\d{4})?\z/, message: "This isn't a valid ZIP code." }
      def kind
        "check"
      end

    end
  end

end
