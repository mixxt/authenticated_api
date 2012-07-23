module AuthenticatedApi

  module Server
    autoload :Middleware, 'authenticated_api/server/middleware'

    def self.valid_signature?(request)
      pp request
      pp request.params
    end
  end

end