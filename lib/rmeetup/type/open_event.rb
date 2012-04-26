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

    class OpenEvent

      attr_accessor :open_event

      def initialize(open_event = {})
        self.open_event = open_event
      end

      def method_missing(id, *args)
        return self.open_event[id.id2name]
      end


      # Special accessors that need typecasting or other parsing
=begin
      def id
        self.open_event['id'].to_i
      end
=end
      def lat
        self.open_event['lat'].to_f
      end
      def lon
        self.open_event['lon'].to_f
      end
=begin
      def rsvpcount
        self.event['rsvpcount'].to_i
      end
      def updated
        DateTime.parse(self.event['updated'])
      end
=end

      def time
        DateTime.parse(self.open_event['time'])
      end
    end
  end
end