class OrganizerPosition::Spending::Control < ApplicationRecord
  belongs_to :organizer_position
  has_many :allowances

  validates :one_active_control

  def one_active_control
    if organizer_position.spending_controls.where(active: true).size > 1
      errors.add(:organizer_position, "may only have one active spending control")
    end
  end

end
