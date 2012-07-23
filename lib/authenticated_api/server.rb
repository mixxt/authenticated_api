module AuthenticatedApi

  module Server
    autoload :Middleware, 'authenticated_api/server/middleware'

    # Determines if the request is authentic given the request and the client's
    # secret key. Returns true if the request is authentic and false otherwise.
    def self.authentic?(request, secret_key)
      return false if secret_key.nil?

      headers = Headers.new(request)
      if match_data = parse_auth_header(headers.authorization_header)
        hmac = match_data[2]
        return hmac == hmac_signature(request, secret_key)
      end

      false
    end

    # Returns the access id from the request's authorization header
    def self.access_id(request)
      headers = Headers.new(request)
      if match_data = parse_auth_header(headers.authorization_header)
        return match_data[1]
      end

      nil
    end

    private
    def self.parse_auth_header(auth_header)
      Regexp.new("APIAuth ([^:]+):(.+)$").match(auth_header)
    end
  end

end