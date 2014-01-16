module AuthenticatedApi

  # Helper class to generate a signature from request method, host, uri, and params
  # Implements Amazons SimpleDB Auth algorithm
  # http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/HMACAuth.html
  # StringToSign = HTTPVerb + "\n" +
  #    ValueOfHostHeaderInLowercase + "\n" +
  #    HTTPRequestURI + "\n" +
  #    CanonicalizedQueryString <from the preceding step>
  class Signature < Struct.new(:method, :body_md5, :content_type, :host, :uri, :params)

    # Turns the params into a canonicalized string
    # Keys are sorted alphabetically
    # @example conversion of params
    #   {foo: 'bar', bar: 'foo'}
    #   # converts to
    #   'bar=foo&foo=bar'
    # @return [String] canonical params
    def canonicalized_params
      params.collect do |key, value|
        "#{key}=#{value}"
      end.sort.join('&')
    end

    # The complete string to be signed, composed of the cased method and host, uri/path and the canonical params
    # @example composed example string
    #   "GET\nexample.org\n/\nfoo=bar"
    # @return [String] composed string
    def string_to_sign
      if content_type.nil?
        "#{method.upcase}\n#{host.downcase}\n#{uri}#{canonicalized_params}"
      else
        "#{method.upcase}\n#{body_md5}\n#{content_type}\n#{host.downcase}\n#{uri}#{canonicalized_params}"
      end
    end

    # Signs the string_to_sign with a given secret
    # @return [String] generated Signature
    def sign_with(secret)
      #puts "Signing #{string_to_sign.inspect} with #{secret.inspect}"
      digest = OpenSSL::Digest.new('sha256')
      Base64.encode64(OpenSSL::HMAC.digest(digest, secret, string_to_sign)).strip
    end

  end

end
