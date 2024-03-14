# frozen_string_literal: true

class BankAccountPolicy < ApplicationPolicy
  only_admins_can :index?, :new?, :update?, :create?, :show?, :reauthenticate?
end
