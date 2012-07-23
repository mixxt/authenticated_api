require 'openssl'
require 'base64'

require 'authenticated_api/errors'
require 'authenticated_api/helpers'
require 'authenticated_api/base'

module AuthenticatedApi
  autoload :Headers, 'authenticated_api/headers'

  module RequestDrivers
    autoload :NetHttpRequest, 'authenticated_api/request_drivers/net_http'
    autoload :CurbRequest, 'authenticated_api/request_drivers/curb'
    autoload :RestClientRequest, 'authenticated_api/request_drivers/rest_client'
  end

end




