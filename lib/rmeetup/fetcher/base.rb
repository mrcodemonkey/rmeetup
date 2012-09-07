module RMeetup
  module Fetcher
    class ApiError < StandardError
      def initialize(error_message, request_url)
        super "Meetup API Error: #{error_message} - API URL: #{request_url}"
      end
    end

    class NoResponseError < StandardError
      def initialize
        super "No Response was returned from the Meetup API."
      end
    end

    # == RMeetup::Fetcher::Base
    #
    # Base fetcher class that other fetchers
    # will inherit from.
    class Base
      def initialize
        @type = nil
      end

      # Fetch and parse a response
      # based on a set of options.
      # Override this method to ensure
      # neccessary options are passed
      # for the request.
      def fetch(options = {})
        url = build_url(options)

        json = get_response(url)

        data = JSON.parse(json)

        # Check to see if the api returned an error
        raise ApiError.new(data['details'],url) if data.has_key?('problem')

        collection = RMeetup::Collection.build(data)

        # Format each result in the collection and return it
        collection.map!{|result| format_result(result)}
      end


      #deliver function to handle post request for rsvp
      def deliver(options = {})

        #add access token if it exists
        url = ""
        if options['access_token']
          url = "https://api.meetup.com/2/rsvp.json?#{options['access_token']}"
        else
          url = "https://api.meetup.com/2/rsvp.json"
        end

        #puts "this is the #{url}"
        #puts "these are the options #{options.to_yaml}"
        response = post_response(url,options)

        #puts response.to_yaml

        #puts "delivered ..."

        if response == "OK"
          puts "rsvp ok"
        else
          puts response.to_yaml
        end

      end


      protected
      # OVERRIDE this method to format a result section
      # as per Result type.
      # Takes a result in a collection and
      # formats it to be put back into the collection.
      def format_result(result)
        result
      end

      def build_url(options)
        options = encode_options(options)

        base_url + params_for(options)
      end

      def base_url

        if @type == :open_events
          "http://api.meetup.com/2/#{@type}.json/"
        else
          "http://api.meetup.com/#{@type}.json/"
        end

      end

      # Create a query string from an options hash
      def params_for(options)
        params = []
        options.each do |key, value|
          params << "#{key}=#{value}"
        end
        "?#{params.join("&")}"
      end

      # Encode a hash of options to be used as request parameters
      def encode_options(options)
        options.each do |key,value|
          options[key] = URI.encode(value.to_s)
        end
      end

      def get_response(url)
        Net::HTTP.get_response(URI.parse(url)).body || raise(NoResponseError.new)


      end

      def post_response(url,options)
        require 'net/https'

        uri = URI.parse(url)

        request = Net::HTTP::Post.new(uri.path)

        #put options in form request
        if options[:key]
          request.set_form_data('key'=>options[:key],'event_id'=>options[:event_id],'rsvp'=>options[:rsvp])
        else
          request.set_form_data('event_id'=>options[:event_id],'rsvp'=>options[:rsvp])
        end

        puts "this is the request #{request.to_yaml}"

        httpr = Net::HTTP.new(uri.host,uri.port)
        httpr.use_ssl=true

        res = httpr.start {|http| http.request(request)}


        case res
          when Net::HTTPSuccess, Net::HTTPRedirection
            # OK
            return "OK"
          else
            #Net::HTTPServerException: 401 "Unauthorized"
            return res.value
        end

      end

    end
  end
end