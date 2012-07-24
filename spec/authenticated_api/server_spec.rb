require 'spec_helper'

describe AuthenticatedApi::Server do

  let(:secret) do
    'secret'
  end
  let(:valid_signature) do
    AuthenticatedApi::Signature.new('get', 'example.org', '/', {'foo' => 'bar'}).sign_with(secret)
  end
  let(:invalid_signature) do
    AuthenticatedApi::Signature.new('get', 'example.org', '/', {'foo' => 'bar'}).sign_with('I dont know the secret')
  end
  let(:valid_request) do
    Rack::Request.new(Rack::MockRequest.env_for("/?foo=bar&Signature=#{CGI::escape(valid_signature)}"))
  end
  let(:invalid_request) do
    Rack::Request.new(Rack::MockRequest.env_for("/?foo=bar&Signature=#{CGI::escape(invalid_signature)}"))
  end

  it "should accept signature of valid request" do
    AuthenticatedApi::Server.valid_signature?(valid_request, secret).should be true
  end
  it "should not accept signature of invalid request" do
    AuthenticatedApi::Server.valid_signature?(invalid_request, secret).should be false
  end

end