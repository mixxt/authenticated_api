module AuthenticatedApi

  module Client
    extend Helpers

    # Raised when the HTTP request object passed is not supported
    class UnknownHTTPRequest < StandardError; end

    autoload :Headers, 'authenticated_api/client/headers'

    module RequestDrivers
      autoload :NetHttpRequest, 'authenticated_api/client/request_drivers/net_http'
      autoload :CurbRequest, 'authenticated_api/client/request_drivers/curb'
      autoload :RestClientRequest, 'authenticated_api/client/request_drivers/rest_client'
    end

    # Signs an HTTP request using the client's access id and secret key.
    # Returns the HTTP request object with the modified headers.
    #
    # request: The request can be a Net::HTTP, ActionController::Request,
    # Curb (Curl::Easy) or a RestClient object.
    #
    # access_id: The public unique identifier for the client
    #
    # secret_key: assigned secret key that is known to both parties
    def self.sign!(request, access_id, secret_key)
      headers = Headers.new(request)
      headers.sign_header auth_header(request, access_id, secret_key)
    end

    private

    def self.hmac_signature(request, secret_key)
      headers = Headers.new(request)
      canonical_string = headers.canonical_string
      digest = OpenSSL::Digest::Digest.new('sha1')
      b64_encode(OpenSSL::HMAC.digest(digest, secret_key, canonical_string))
    end

    def self.auth_header(request, access_id, secret_key)
      "APIAuth #{access_id}:#{hmac_signature(request, secret_key)}"
    end

  end

end