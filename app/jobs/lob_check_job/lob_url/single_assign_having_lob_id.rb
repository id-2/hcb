# frozen_string_literal: true

module LobCheckJob
  module LobUrl
    class SingleAssignHavingLobId < ApplicationJob
      def perform(check:)
        LobCheckService::LobUrl::SingleAssignHavingLobId.new(check: check).run
      end

    end
  end
end
