class OrganizerPosition
  module Spending
    extend ActiveSupport::Concern
    included do
      has_many :spending_allowances, class_name: "OrganizerPosition::Spending::Allowance"
      has_many :spending_controls, class_name: "OrganizerPosition::Spending::Control"
    end

    def spending_control_enabled?
      active_spending_control
    end

    def spending_control_disabled?
      !spending_control_enabled?
    end
  end

end
