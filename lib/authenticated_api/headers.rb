module AuthenticatedApi
  
  # Builds the canonical string given a request object.
  class Headers
    
    def initialize(request)
      @original_request = request
      
      case request.class.to_s
      when /Net::HTTP/
        @request = RequestDrivers::NetHttpRequest.new(request)
      when /RestClient/
        @request = RequestDrivers::RestClientRequest.new(request)
      when /Curl::Easy/
        @request = RequestDrivers::CurbRequest.new(request)
      else
        raise UnknownHTTPRequest, "#{request.class.to_s} is not yet supported."
      end
      true
    end
    
    # Returns the canonical string computed from the request's headers
    def canonical_string
      [ @request.content_type,
        @request.content_md5,
        @request.request_uri,
        @request.timestamp
      ].join(",")
    end
    
    # Returns the authorization header from the request's headers
    def authorization_header
      @request.authorization_header
    end
    
    # Sets the request's authorization header with the passed in value.
    # The header should be the AuthenticatedApi HMAC signature.
    #
    # This will return the original request object with the signed Authorization
    # header already in place.
    def sign_header(header)
      @request.set_auth_header header
    end
    
  end
  
end
