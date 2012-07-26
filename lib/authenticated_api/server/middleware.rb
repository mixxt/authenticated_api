module AuthenticatedApi

  module Server

    # Rack Middleware to verify incoming requests
    class Middleware

      # Initialize the Middleware
      # @param [Object] app Rack app
      # @param [Hash] accounts account hash to get shared_secret for AccessKeyID
      # @param [Hash] options
      # @option options [Boolean] :force Aborts unsigned requests if set to true
      def initialize(app, accounts, options = {})
        @app = app
        @accounts = accounts
        @options = options
      end

      # sets signature.valid if the signature is valid
      # Aborts with status 403 if force option is set and request is invalid
      # @param [Hash] env Rack environment
      def call(env)
        env['signature.valid'] = valid?(env)
        if @options[:force] && !env['signature.valid']
          [403, { 'Content-Type' => 'text/plain' }, ['Request Signature missing or invalid']]
        else
          @app.call(env)
        end
      end

      # validates a request environment
      # fetches shared_secret for AccessKeyID
      # @param [Hash] env Rack environment
      # @return [Boolean] true if signature could be validated
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