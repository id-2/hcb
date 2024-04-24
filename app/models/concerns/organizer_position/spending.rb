class OrganizerPosition
  module Spending
    extend ActiveSupport::Concern
    included do
      has_many :spending_allowances, class_name: "OrganizerPosition::Spending::Allowance"
      has_many :spending_controls, class_name: "OrganizerPosition::Spending::Control"
      # has_one :active_spending_control, -> { where(spending_controls: { active: true }) }
    end

    def spending_control_enabled?
      active_spending_control
    end
  
    def spending_control_disabled?
      !spending_control_enabled?
    end

    private

    # def at_least_one_manager
    #   event&.organizer_positions&.where(role: :manager)&.any?
    # end

    # def signee_is_manager
    #   return unless is_signee && role != "manager"

    #   errors.add(:role, "must be a manager because the user is a legal owner.")
    # end
  end

end
