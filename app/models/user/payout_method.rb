# frozen_string_literal: true

class User
  module PayoutMethod
    def self.table_name_prefix
      "user_payout_method_"
    end

    def kind
      "unknown"
    end
  end

end
