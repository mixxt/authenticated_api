module AuthenticatedApi

  module Server

    class Middleware

      def initialize(app, accounts, options = {})
        @app = app
        @accounts = accounts
        @options = options
      end

      def call(env)
        env['signature.valid'] = valid?(env)
        @app.call(env)
      end

      def valid?(env)
        request = Rack::Request.new(env)
        unless (access_id = request.params['AccessKeyID'])
          #puts "AccessKeyID not found in Params"
          return false
        end
        unless (secret_key = @accounts[access_id])
          #puts "No SecretKey found for AccessKeyID #{access_id.inspect}"
          return false
        end
        AuthenticatedApi::Server.valid_signature?(request, secret_key)
      end

    end

  end

end