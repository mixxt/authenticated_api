require 'digest/md5'
require 'net/http'
require 'rack'
require 'cgi'

module AuthenticatedApi

  # Client helper class to auto-sign requests with predefined credentials
  class Client

    # Create a new Client Connection to host:port and sign requests with secret for access_key
    # @param [String] host Host to connect to, example: 'api.example.org'
    # @param [String, Integer] port port to use, pass in default 80 if port is unknown
    # @param [String, Integer] acces_key AccessKeyID to send with requests
    # @param [String] secret Secret to sign requests with
    # @return [AuthenticatedApi::Client] instance of client
    def initialize(host, port, access_key, secret)
      @http = Net::HTTP.new(host, port)
      @access_id = access_key.to_s
      @secret = secret
    end

    # Sign a Net::HTTP::Request Object with predefined secret and append Signature and AccessKeyID to get params
    # @param [Net::HTTP::Request] request Instance of subclass of Net::HTTP::Request, example: Net::HTTP::Get.new('/')
    # @return [Net::HTTPResponse] response from Net::HTTP#request
    def request(request)
      changed_uri = URI.parse(request.path)
      body_md5 =
        if request.body_stream.present?
          request.body_stream.rewind
          checksum = Digest::MD5.hexdigest(request.body_stream.read)
          request.body_stream.rewind
          checksum
        elsif request.body.present?
          Digest::MD5.hexdigest(request.body.to_s)
        else
          ''
        end

      params = Rack::Utils.parse_nested_query(changed_uri.query)
      host = @http.address
      signature = Signature.new(request.method, body_md5, request['content-type'], host, changed_uri.path, params).sign_with(@secret)

      changed_uri.query = (changed_uri.query ? "#{changed_uri.query}&" : '') + "Signature=#{CGI::escape(signature)}&AccessKeyID=#{CGI::escape(@access_id)}"
      request.instance_eval do
        @path = changed_uri.to_s
      end

      @http.request(request)
    end
  end
end
