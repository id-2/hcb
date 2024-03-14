# frozen_string_literal: true

class HcbCodePolicy < ApplicationPolicy
  only_admins_can :memo_frame?, :send_receipt_sms?

  permit_admins_to def show?
    user_is_organizer?
  end

  permit_admins_to def edit?
    user_is_organizer?
  end

  permit_admins_to def update?
    user_is_organizer?
  end

  permit_admins_to def comment?
    user_is_organizer?
  end

  permit_admins_to def attach_receipt?
    user_is_organizer? || user_made_purchase?
  end

  permit_admins_to def dispute?
    user_is_organizer?
  end

  permit_admins_to def pin?
    user_is_organizer?
  end

  permit_admins_to def toggle_tag?
    user_is_organizer?
  end

  permit_admins_to def invoice_as_personal_transaction?
    user_is_organizer?
  end

  permit_admins_to def link_receipt_modal?
    user_is_organizer?
  end

  permit_admins_to def breakdown?
    user_is_organizer?
  end

  def user_made_purchase?
    record.stripe_card? && record.stripe_cardholder&.user == user
  end

  alias receiptable_upload? user_made_purchase?

  private

  def user_is_organizer?
    record.events.select { |e| e.try(:users).try(:include?, user) }.present?
  end

end
