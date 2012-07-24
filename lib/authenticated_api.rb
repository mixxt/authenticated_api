require 'openssl'
require 'securerandom'
require 'base64'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/module/aliasing'

require 'authenticated_api/signature'

module AuthenticatedApi

  autoload :Client, 'authenticated_api/client'
  autoload :Server, 'authenticated_api/server'

  def self.generate_secret_key(n = nil)
    SecureRandom.base64(n)
  end

end




