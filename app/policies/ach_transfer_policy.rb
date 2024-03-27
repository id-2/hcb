# frozen_string_literal: true

class AchTransferPolicy < ApplicationPolicy
  get(:event) { record&.event }

  policy_for :index?,
             :start_approval?,
             :approve?,
             :reject? do
    ⚡
  end

  policy_for :new?, :show? do
    🔎 || user_can_transfer?
  end

  def create?
    user_can_transfer? && !event.demo_mode && !event.outernet_guild?
  end

  def view_account_routing_numbers?
    ⚡ || 👔
  end

  policy_for :cancel?, :transfer_confirmation_letter? do
    user_can_transfer?
  end

  private

  def user_can_transfer?
    user&.admin? || EventPolicy.new(user, event).new_transfer?
  end

end
