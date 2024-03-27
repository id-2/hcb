# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  ⚡ :toggle_hidden?, :new?, :create?

  🔎 ⚡ 👥 :show?

  # NOTE(@lachlanjc): this is bad, I’m sorry.
  # This is the StripeCardsController#shipping method when rendered on the event
  # card overview page. This should be moved out of here.
  ⚡ 👥 :shipping?

  ⚡ :by_airtable_id?

  ⚡ 👥 :edit?

  ⚡ 🧑‍💼 :update?

  def destroy?
    user&.admin? && record.demo_mode?
  end

  🔎 ⚡ 👥 :team?, :emburse_card_overview?, :card_overview?

  def new_stripe_card?
    create_stripe_card?
  end

  def create_stripe_card?
    admin_or_user? && is_not_demo_mode?
  end

  🔎 ⚡ 👥 :documentation?, :statements?

  def demo_mode_request_meeting?
    admin_or_manager? && record.demo_mode? && record.demo_mode_request_meeting_at.nil?
  end

  # (@eilla1) these pages are for the wip resources page and should be moved later
  🔎 ⚡ 👥 :connect_gofundme?, :async_balance?

  def async_balance?
    is_public || admin_or_user?
  end

  def new_transfer?
    admin_or_manager? && !record.demo_mode?
  end

  def receive_check?
    is_public || admin_or_user?
  end

  def sell_merch?
    is_public || admin_or_user?
  end

  def g_suite_overview?
    admin_or_user? && is_not_demo_mode? && !record.hardware_grant?
  end

  def g_suite_create?
    admin_or_manager? && is_not_demo_mode? && !record.hardware_grant?
  end

  def g_suite_verify?
    admin_or_user? && is_not_demo_mode? && !record.hardware_grant?
  end

  def transfers?
    is_public || admin_or_user?
  end

  def promotions?
    (is_public || admin_or_user?) && !record.hardware_grant? && !record.outernet_guild?
  end

  def reimbursements?
    admin_or_user?
  end

  def expensify?
    admin_or_user?
  end

  def donation_overview?
    is_public || admin_or_user?
  end

  def partner_donation_overview?
    is_public || admin_or_user?
  end

  def remove_header_image?
    admin_or_manager?
  end

  def remove_background_image?
    admin_or_manager?
  end

  def remove_logo?
    admin_or_manager?
  end

  def enable_feature?
    admin_or_manager?
  end

  def disable_feature?
    admin_or_manager?
  end

  def account_number?
    admin_or_manager?
  end

  def toggle_event_tag?
    user.admin?
  end

  def receive_grant?
    record.users.include?(user)
  end

  def audit_log?
    user.admin?
  end

  def validate_slug?
    admin_or_user?
  end

  def termination?
    user&.admin?
  end

  private

  def admin_or_user?
    user&.admin? || record.users.include?(user)
  end

  def admin_or_manager?
    user&.admin? || OrganizerPosition.find_by(user:, event: record)&.manager?
  end

  def is_not_demo_mode?
    !record.demo_mode?
  end

  def is_public
    record.is_public?
  end

end
