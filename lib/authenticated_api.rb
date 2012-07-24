require 'openssl'
require 'securerandom'
require 'base64'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/module/aliasing'

require 'authenticated_api/signature'

module AuthenticatedApi

  autoload :Client, 'authenticated_api/client'
  autoload :Server, 'authenticated_api/server'

end




