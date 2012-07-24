module AuthenticatedApi

  module Client

    module RequestDrivers # :nodoc:

      class NetHttpRequest # :nodoc:

        def initialize(request)
          @request = request
          @headers = fetch_headers
          true
        end

        def set_auth_header(header)
          @request["Authorization"] = header
          @headers = fetch_headers
          @request
        end

        def fetch_headers
          @request
        end

        def content_type
          value = find_header(%w(CONTENT-TYPE CONTENT_TYPE HTTP_CONTENT_TYPE))
          value.nil? ? "" : value
        end

        def content_md5
          value = find_header(%w(CONTENT-MD5 CONTENT_MD5))
          value.nil? ? "" : value
        end

        def request_uri
          @request.path
        end

        def timestamp
          value = find_header(%w(DATE HTTP_DATE))
          if value.nil?
            value = Time.now.utc.httpdate
            @request["DATE"] = value
          end
          value
        end

        def authorization_header
          find_header %w(Authorization AUTHORIZATION HTTP_AUTHORIZATION)
        end

        private

        def find_header(keys)
          keys.map {|key| @headers[key] }.compact.first
        end

      end

    end

  end

end