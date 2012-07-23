module AuthenticatedApi

  module Server

    class Middleware

      def initialize(app, accounts, options = {})
        @app = app
        @accounts = accounts
        @options = options
      end

      def call(env)
        request = Rack::Request.new(env)
        env['api.valid_signature'] = AuthenticatedApi::Server.valid_signature?(request)
        @app.call(env)
      end

    end

  end

end