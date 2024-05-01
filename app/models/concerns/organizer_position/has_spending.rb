class OrganizerPosition
  module HasSpending
    extend ActiveSupport::Concern
    included do
      has_many :spending_controls, class_name: "OrganizerPosition::Spending::Control"
      has_one :active_spending_control, -> { where(active: true) }, class_name: "OrganizerPosition::Spending::Control"
    end

    def spending_control_enabled?
      active_spending_control
    end

    def spending_control_disabled?
      !spending_control_enabled?
    end
  end

end
