# frozen_string_literal: true

class BulletinPolicy < ApplicationPolicy
  %i[new create edit update destroy].each do |action|
    define_method("#{action}?") do
      user.admin?
    end
  end

  def show?
    record.visible_to?(user)
  end

end
