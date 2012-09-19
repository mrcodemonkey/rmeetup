require 'net/http'
require 'date'
require 'rubygems'
require 'json'
require 'rmeetup/type'
require 'rmeetup/collection'
require 'rmeetup/fetcher'

module RMeetup
  
  # RMeetup Errors
  class NotConfiguredError < StandardError
    def initialize
      super "Please provide your Meetup API key before fetching data."
    end
  end
  
  class InvalidRequestTypeError < StandardError
    def initialize(type)
      super "Fetch type '#{type}' not a valid."
    end
  end
  
  # == RMeetup::Client
  # 
  # Essentially a simple wrapper to delegate requests to
  # different fetcher classes who are responsible for fetching
  # and parsing their own responses.

  #added open_vents and rsvp

  class Client
    FETCH_TYPES = [:topics, :cities, :members, :rsvps, :events, :groups, :comments, :photos, :open_events,:meetup_profiles, :event_infos]
    POST_TYPES = [:rsvps,:meetup_profiles]

    # Meetup API Key
    # Get one at http://www.meetup.com/meetup_api/key/
    # Needs to be the group organizers API Key
    # to be able to RSVP for other people
    @@api_key = nil
    def self.api_key; @@api_key; end;
    def self.api_key=(key); @@api_key = key; end;
    
    def self.fetch(type, options = {})
      check_configuration!
      
      # Merge in all the standard options
      # Keeping whatever was passed in

      options = default_options.merge(options)

      if FETCH_TYPES.include?(type.to_sym)
        # Get the custom fetcher used to manage options, api call to get a type of response

        fetcher = RMeetup::Fetcher.for(type)
        return fetcher.fetch(options)
      else
        raise InvalidRequestTypeError.new(type)
      end

    end





    #post stuff
    def self.deliver(type,options={})
      check_configuration!
      # Merge in all the standard options
      # Keeping whatever was passed in


     #options = default_options.merge(options)


      if POST_TYPES.include?(type.to_sym)

        if(type.to_sym == :rsvps)
          rsvp = RMeetup::Fetcher.for(type)
          return rsvp.rsvp_post(options)
        elsif (type.to_sym == :meetup_profiles)
          rsvp = RMeetup::Fetcher.for(type)
          return rsvp.profiles_post(options)
        end


      else
        raise InvalidRequestTypeError.new(type)
      end

    end


    def self.refresh_token(options={})
      url = "https://secure.meetup.com/oauth2/access"

      self.send_refresh_post(url,options)
    end










    protected



    def self.send_refresh_post(url,options)

      puts "in send refresh"

      uri = URI.parse(url)
      request = Net::HTTP::Post.new(uri.path)

      #set form request variables www-url-encoded
      request.set_form_data({ 'client_id' => options[:client_id] ,
                          'client_secret' => options[:client_secret],
                          'grant_type' => "refresh_token",
                          'refresh_token' => options[:refresh_token]
                        })

      http_r = Net::HTTP.new(uri.host,uri.port)
      http_r.use_ssl=true
      http_r.ssl_version='SSLv3'

      res = http_r.start {|http| http.request(request)}

      puts res.to_yaml

      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          # OK
          puts res.to_yaml
          return res
        else
          #Net::HTTPServerException: 401 "Unauthorized"
          puts res.to_yaml
          return res.value
      end

    end



      def self.default_options
        {
          :key => api_key
        }
      end
      
      # Raise an error if RMeetup has not been
      # provided with an api key
      def self.check_configuration!
        raise NotConfiguredError.new unless api_key
      end
  end
end