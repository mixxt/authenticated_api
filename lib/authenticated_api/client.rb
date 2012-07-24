module AuthenticatedApi

  class Client

    def initialize(host, port, access_id, secret)
      @http = Net::HTTP.new(host, port)
      @access_id = access_id.to_s
      @secret = secret
    end

    def request(request)
      changed_uri = URI.parse(request.path)
      post = request.body ? URI.decode_www_form(request.body) : {}
      params = post.merge(Rack::Utils.parse_nested_query(changed_uri.query))
      host = @http.address
      signature = Signature.new(request.method, host, changed_uri.path, params).sign_with(@secret)

      changed_uri.query = changed_uri.query + "&Signature=#{CGI::escape(signature)}&AccessKeyID=#{CGI::escape(@access_id)}"
      request.instance_eval do
        @path = changed_uri.to_s
      end

      @http.request(request)
    end

  end

end