# frozen_string_literal: true

class HcbCodePolicy < ApplicationPolicy
  only_admins_can :memo_frame?, :send_receipt_sms?

  permit_admins_to def show?
    present_in_events?
  end

  permit_admins_to def edit?
    present_in_events?
  end

  permit_admins_to def update?
    present_in_events?
  end

  permit_admins_to def comment?
    present_in_events?
  end

  permit_admins_to def attach_receipt?
    present_in_events? || user_made_purchase?
  end

  permit_admins_to def dispute?
    present_in_events?
  end

  permit_admins_to def pin?
    present_in_events?
  end

  permit_admins_to def toggle_tag?
    present_in_events?
  end

  permit_admins_to def invoice_as_personal_transaction?
    present_in_events?
  end

  permit_admins_to def link_receipt_modal?
    present_in_events?
  end

  permit_admins_to def breakdown?
    present_in_events?
  end

  def user_made_purchase?
    record.stripe_card? && record.stripe_cardholder&.user == user
  end

  alias receiptable_upload? user_made_purchase?

  private

  def present_in_events?
    record.events.select { |e| e.try(:users).try(:include?, user) }.present?
  end

end
