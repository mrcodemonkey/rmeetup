module RMeetup
  module Fetcher
    class EventInfos < Base
      def initialize
        @type = :event_infos
      end

      # Turn the result hash into a Event Class
      def format_result(result)
        RMeetup::Type::EventInfo.new(result)
      end
    end
  end
end