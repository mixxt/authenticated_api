module AuthenticatedApi

  class Signature < Struct.new(:method, :host, :uri, :params)

    #http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/HMACAuth.html
    #StringToSign = HTTPVerb + "\n" +
    #    ValueOfHostHeaderInLowercase + "\n" +
    #    HTTPRequestURI + "\n" +
    #    CanonicalizedQueryString <from the preceding step>

    def canonicalized_params
      params.collect do |key, value|
        "#{key}=#{value}"
      end.sort.join('&')
    end

    def string_to_sign
      "#{method.upcase}\n#{host.downcase}\n#{uri}#{canonicalized_params}"
    end

    def sign_with(secret)
      digest = OpenSSL::Digest::Digest.new('sha256')
      Base64.encode64(OpenSSL::HMAC.digest(digest, secret, string_to_sign)).strip
    end

  end

end