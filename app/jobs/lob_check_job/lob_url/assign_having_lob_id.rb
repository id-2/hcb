# frozen_string_literal: true

module LobCheckJob
  module LobUrl
    class AssignHavingLobId < ApplicationJob
      def perform
        CheckService::LobUrl::AssignHavingLobId.new.run
      end

    end
  end
end
