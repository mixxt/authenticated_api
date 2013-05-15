module AuthenticatedApi
  module ActiveResourceExtension
    def self.included(base)
      base.extend(ClassMethods)

      if base.respond_to?('class_attribute')
        base.class_attribute :access_key
        base.class_attribute :shared_secret
        base.class_attribute :use_authenticated_api
      else
        base.class_inheritable_accessor :access_key
        base.class_inheritable_accessor :shared_secret
        base.class_inheritable_accessor :use_authenticated_api
      end

      if defined?(ActiveResource)
        ActiveResource::Connection.send(:include, Connection) unless ActiveResource::Connection.include?(Connection)
      end
    end

    module ClassMethods
      def with_authenticated_api(access_key, shared_secret)
        self.access_key = access_key
        self.shared_secret = shared_secret
        self.use_authenticated_api = true

        class << self
          alias_method_chain :connection, :authenticated_api
        end
      end

      def connection_with_authenticated_api(refresh = false)
        connection = connection_without_authenticated_api(refresh)
        connection.access_key = self.access_key
        connection.shared_secret = self.shared_secret
        connection.use_authenticated_api = self.use_authenticated_api
        connection
      end
    end

    module InstanceMethods
    end

    module Connection
      class Client
        def initialize(host, port, access_key, shared_secret)
          @access_key = access_key
          @shared_secret = shared_secret
          @client = AuthenticatedApi::Client.new(host, port, @access_key, @shared_secret)
        end

        def method_missing(method, *args, &block)
          if %i{ get delete post put patch }.include?(method)
            header = args.last
            path = args.first
            request = "Net::HTTP::#{method.to_s.capitalize}".constantize.new(path, header)
            request.body = args[1] if args.length > 2
            @client.request(request)
          end
        end
      end

      def self.included(base)
        base.send :alias_method_chain, :new_http, :authenticated_api
        base.class_eval do
          attr_accessor :shared_secret, :access_key, :use_authenticated_api
        end
      end

      def new_http_with_authenticated_api
        if use_authenticated_api
          Client.new(site.host, site.port, access_key, shared_secret)
        else
          new_http_without_authenticated_api
        end
      end
    end
  end
end
