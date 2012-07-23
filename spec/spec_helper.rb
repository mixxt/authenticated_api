require "bundler/setup"
Bundler.require

require 'api_auth'

ENV['RACK_ENV'] = 'test'

require 'rack'
require 'rack/test'
require 'amatch'
require 'rest_client'
require 'curb'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
