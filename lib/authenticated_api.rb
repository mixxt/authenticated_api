require 'openssl'
require 'base64'

require 'authenticated_api/helpers'

module AuthenticatedApi
  extend Helpers

  # Generates a Base64 encoded, randomized secret key
  #
  # Store this key along with the access key that will be used for
  # authenticating the client
  def self.generate_secret_key
    random_bytes = OpenSSL::Random.random_bytes(512)
    b64_encode(Digest::SHA2.new(512).digest(random_bytes))
  end

  # :nodoc:
  class ApiAuthError < StandardError; end

  autoload :Client, 'authenticated_api/client'
  autoload :Server, 'authenticated_api/server'

end




