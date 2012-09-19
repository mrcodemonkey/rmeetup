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

        puts "this is the url #{url}"
        puts "these are the options #{options}"

        json = get_response(url)

        puts json.to_yaml

        data = JSON.parse(json)

        #puts "dump data after parse: #{data.to_yaml}"

        # Check to see if the api returned an error
        raise ApiError.new(data['details'],url) if data.has_key?('problem')


        if !options[:id]

        puts "in options"

        collection = RMeetup::Collection.build(data)

        #puts "value of collection:#{collection.to_yaml}"

        # Format each result in the collection and return it
        collection.map!{|result| format_result(result)}

        else
          puts "not in options"
          return data

        end


      end


      #deliver function to handle post request for rsvp
      def rsvp_post(options = {})

        #add access token if it exists
        url = ""
        if options[:access_token]
          #url = "https://api.meetup.com/2/rsvp?access_token=#{options[:access_token]}"
          url = "https://api.meetup.com/2/rsvp.json"

        else
          url = "https://api.meetup.com/2/rsvp"
        end

        puts "url posting is #{url}"

        response = post_response(url,options)

        if response == "OK"
          puts "rsvp ok"
        else
          puts response.to_yaml
        end
      end


      #deliver function to handle post request for rsvp
      def profiles_post(options = {})

=begin
        #add access token if it exists
        url = ""
        if options[:access_token]
          url = "https://api.meetup.com/2/profile.json?access_token=#{options[:access_token]}"
          #url = "https://api.meetup.com/2/profile.json"
        else
          url = "https://api.meetup.com/2/profile.json"
        end
=end

        url = "https://api.meetup.com/2/profile.json"

        puts "profiles post url #{url}"

        response = post_response(url,options)

        if response == "OK"
          puts "OK"
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

        puts "dump of options: #{options.to_yaml}"

        options = encode_options(options)

        url = ""

        if options[:id]
          url = base_url + "#{options[:id]}.json" + params_for(options)
        else

          url = base_url +  params_for(options)

        end



        return url
      end

      def base_url

        if @type == :open_events
          "http://api.meetup.com/2/#{@type}.json/"
        elsif @type == :event_infos
          "http://api.meetup.com/2/event/"
        elsif @type == :meetup_profiles
          "http://api.meetup.com/2/profiles.json/"
        elsif @type == :groups
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

        puts "in post response"
        puts "dumpin options #{options}"

        if options[:rsvp]

          puts "in rsvp section"

          #put options in form request
          if options[:key]
            puts "options key"
            request.set_form_data('key'=>options[:key],'event_id'=>options[:event_id],'rsvp'=>options[:rsvp])
          else
            puts "options without key"
            request.set_form_data({'access_token'=>options[:access_token],'event_id'=>options[:event_id],'rsvp'=>options[:rsvp]})
        end


        elsif options[:group_id]

          puts "using meetup profiles"

          #put options in form request
          if options[:key]
            puts "using key"
            request.set_form_data('key'=> options[:key],'group_id'=>options[:group_id])
          else
            puts "not using key"
            request.set_form_data('access_token'=>options[:access_token],'group_id'=>options[:group_id])
          end

        end


        httpr = Net::HTTP.new(uri.host,uri.port)
        httpr.use_ssl=true
        httpr.ssl_version='SSLv3'

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