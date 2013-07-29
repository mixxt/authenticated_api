module AuthenticatedApi
  class FaradayMiddleware
    # Faraday Middleware
    def initialize(app, access_key, shared_secret)
      @app = app
      @access_key = access_key
      @shared_secret = shared_secret
    end

    def call(env)
      uri = env[:url]
      params = Rack::Utils.parse_nested_query uri.query
      signature = AuthenticatedApi::Signature.new(env[:method], Digest::MD5.hexdigest(env[:body].to_s || ''),
                                                  env[:request_headers]['Content-Type'], uri.host, uri.path,
                                                  params).sign_with(@shared_secret)

      params.merge! 'Signature' => signature, 'AccessKeyID' => @access_key
      uri.query = Rack::Utils.build_query params

      @app.call(env)
    end
  end
end
