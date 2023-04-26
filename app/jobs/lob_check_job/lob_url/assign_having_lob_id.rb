# frozen_string_literal: true

module LobCheckJob
  module LobUrl
    class AssignHavingLobId < ApplicationJob
      def perform
        LobCheckService::LobUrl::AssignHavingLobId.new.run
      end

    end
  end
end
