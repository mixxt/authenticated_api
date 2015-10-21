require "bundler/setup"
Bundler.require

require 'authenticated_api'

ENV['RACK_ENV'] = 'test'

require 'rack'
require 'rack/test'
require 'amatch'
require 'rest_client'
require 'fakeweb'

FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
