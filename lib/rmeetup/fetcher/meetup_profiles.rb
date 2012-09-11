module RMeetup
  module Fetcher
    class MeetupProfiles < Base
      def initialize
        @type = :meetup_profiles
      end

      # Turn the result hash into a Topic Class
      def format_result(result)
        RMeetup::Type::MeetupProfile.new(result)
      end
    end
  end
end