# frozen_string_literal: true

class PaymentRecipientPolicy < ApplicationPolicy
  permit_admins_to def destroy?
    record.event.users.include?(user)
  end

end
