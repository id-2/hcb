# frozen_string_literal: true

module CheckService
  module LobUrl
    class AssignHavingLobId
      def run
        checks.each do |check|
          LobCheckJob::LobUrl::SingleAssignHavingLobId.perform_later(check: check)
        end
      end

      private

      def checks
        @checks ||= Check.where("lob_id is not null")
      end

    end
  end
end
