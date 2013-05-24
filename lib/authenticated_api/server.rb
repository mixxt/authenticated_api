module AuthenticatedApi

  # Namespace for server related classes and methods
  module Server
    autoload :Middleware, 'authenticated_api/server/middleware'

    # Tells if the signature on a Rack::Request compatible object is valid, according to the given secret
    # @param [Rack::Request] request Request object
    # @param [String] secret Shared secret the request should be signed with
    # @return [Boolean] true if the signature is valid
    def self.valid_signature?(request, secret)
      request.params['Signature'] == signature_for_request(request, secret)
    end

    # Generates a reference signature for a Rack::Request compatible object with the given secret
    # @param [Rack::Request] request Request object
    # @param [String] secret Shared secret
    # @return [String] Signature for request
    def self.signature_for_request(request, secret)
      body_str = ''
      if request.body
        body_str = request.body.read
	request.body.rewind
      end
      body_md5 = Digest::MD5.hexdigest(body_str)
      Signature.new(request.request_method, body_md5, request.content_type, request.host, request.env['REQUEST_PATH'] || request.path_info, request.params.except('Signature', 'AccessKeyID')).sign_with(secret)
    end
  end

end