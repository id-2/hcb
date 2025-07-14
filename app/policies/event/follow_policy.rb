# frozen_string_literal: true

class Event
  class FollowPolicy < ApplicationPolicy
    def create?
      user == record.user && policy(record.event).announcement_overview?
    end

    def destroy?
      user == record.user
    end

  end

end
