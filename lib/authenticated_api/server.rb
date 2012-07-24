module AuthenticatedApi

  module Server
    autoload :Middleware, 'authenticated_api/server/middleware'

    def self.valid_signature?(request, secret)
      request.params['Signature'] == AuthenticatedApi.signature_for_request(request, secret)
    end

    def self.signature_for_request(request, secret)
      Signature.new(request.request_method, request.host, request.path_info, request.params.except('Signature', 'AccessKeyID')).sign_with(secret)
    end
  end

end