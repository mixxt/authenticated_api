require 'openssl'
require 'securerandom'
require 'base64'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/module/aliasing'

require 'authenticated_api/signature'

# The namespace for all classes
module AuthenticatedApi

  autoload :Client, 'authenticated_api/client'
  autoload :Server, 'authenticated_api/server'

  autoload :FaradayMiddleware, 'authenticated_api/clients/faraday_middleware'
  autoload :ActiveResourceExtension, 'authenticated_api/extensions/active_resource'

  # Helper method, may or may not be used
  def self.generate_secret_key(n = nil)
    SecureRandom.base64(n)
  end
end
