module RMeetup
  module Type

    # == RMeetup::Type::Event
    #
    # Data wraper for a Event fethcing response
    # Used to access result attributes as well
    # as progammatically fetch relative data types
    # based on this event.

    # Edited by Jason Berlinsky on 1/20/11 to allow for arbitrary data access
    # See http://www.meetup.com/meetup_api/docs/events/ for available fields

    class EventInfo

      attr_accessor :event_info

      def initialize(event_info = {})
        self.event_info = event_info
      end

      def method_missing(id, *args)
        return self.event_info[id.id2name]
      end

      # Special accessors that need typecasting or other parsing
      def id
        self.event_info['id'].to_i
      end
      def lat
        self.event_info['lat'].to_f
      end
      def lon
        self.event_info['lon'].to_f
      end
      def rsvpcount
        self.event_info['rsvpcount'].to_i
      end
      def updated
        DateTime.parse(self.event_info['updated'])
      end
      def time
        DateTime.parse(self.event_info['time'])
      end
    end
  end
end