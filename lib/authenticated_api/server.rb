module AuthenticatedApi

  module Server
    autoload :Middleware, 'authenticated_api/server/middleware'

    def self.valid_signature?(request, secret)
      #puts "Comparing #{request.params['Signature'].inspect} with #{signature_for_request(request, secret)}"
      request.params['Signature'] == signature_for_request(request, secret)
    end

    def self.signature_for_request(request, secret)
      Signature.new(request.request_method, request.host, request.env['REQUEST_PATH'], request.params.except('Signature', 'AccessKeyID')).sign_with(secret)
    end
  end

end