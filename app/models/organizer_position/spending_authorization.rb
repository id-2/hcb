class OrganizerPosition::SpendingAuthorization < ApplicationRecord
  belongs_to :organizer_position

  def total_spent
  end

  def total_allocated
  end

  def balance
  end
end
