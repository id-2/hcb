# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  get(:event) { record }

  def index?
    user.present?
  end

  policy_for :toggle_hidden?, :new?, :create?, :by_airtable_id?, :termination?, :toggle_event_tag?, :audit_log? do
    ⚡
  end

  policy_for :show?,
             :team?,
             :emburse_card_overview?,
             :card_overview?,
             :documentation?,
             :statements?,
             :connect_gofundme?,
             :async_balance?,
             :receive_check?,
             :sell_merch?,
             :transfers?,
             :donation_overview?,
             :partner_donation_overview? do
    🔎 || ⚡ || 👥
  end

  policy_for :edit, :shipping?, :reimbursements?, :expensify?, :validate_slug? do
    ⚡ || 👥
  end

  policy_for :update?, :remove_header_image?, :remove_background_image?, :remove_logo?, :enable_feature?, :disable_feature?, :account_number? do
    ⚡ || 👔
  end

  def destroy?
    ⚡ && record.demo_mode?
  end

  policy_for :new_stripe_card?, :create_stripe_card? do
    (⚡ || 👥) && !record.demo_mode?
  end

  def demo_mode_request_meeting?
    (⚡ || 👔) && record.demo_mode? && record.demo_mode_request_meeting_at.nil?
  end

  def new_transfer?
    (⚡ || 👔) && !record.demo_mode?
  end

  policy_for :g_suite_overview?, :g_suite_verify? do
    (⚡ || 👥) && !record.demo_mode? && !record.hardware_grant?
  end

  def g_suite_create?
    (⚡ || 👔) && !record.demo_mode? && !record.hardware_grant?
  end

  def promotions?
    (🔎 || ⚡ || 👥) && !record.hardware_grant? && !record.outernet_guild?
  end

  def receive_grant?
    👥
  end

end
