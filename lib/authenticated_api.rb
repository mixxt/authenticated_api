require 'openssl'
require 'base64'

module AuthenticatedApi
  require 'authenticated_api/errors'
  require 'authenticated_api/helpers'

  module RequestDrivers
    autoload :NetHttpRequest, 'authenticated_api/request_drivers/net_http'
    autoload :CurbRequest, 'authenticated_api/request_drivers/curb'
    autoload :RestClientRequest, 'authenticated_api/request_drivers/rest_client'
  end

  require 'authenticated_api/headers'
  require 'authenticated_api/base'
end




