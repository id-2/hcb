# frozen_string_literal: true

class ReceiptablePolicy < ApplicationPolicy
  permit_admins_to def link?
    present_in_events? || Pundit.policy(user, record).try(:receiptable_upload?)
  end

  permit_admins_to def link_modal?
    present_in_events? || Pundit.policy(user, record).try(:receiptable_upload?)
  end

  permit_admins_to def upload?
    present_in_events? || Pundit.policy(user, record).try(:receiptable_upload?)
  end

  private

  def present_in_events?
    # Assumption: Receiptable has an association to Event
    events = record.try(:events) || [record.event]
    events.select { |e| e.try(:users).try(:include?, user) }.present?
  end

end
