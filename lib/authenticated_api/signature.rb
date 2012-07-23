module AuthenticatedApi

  class Signature < Struct.new(:method, :host, :uri, :params)

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

  end

end