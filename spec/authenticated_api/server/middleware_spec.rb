require 'spec_helper'

describe AuthenticatedApi::Server::Middleware do

  let(:canonical_string) do
    "implement"
  end
  let(:hmac_signature) do
    digest = OpenSSL::Digest::Digest.new('sha1')
    Base64.encode64(OpenSSL::HMAC.digest(digest, secret_key, canonical_string)).strip
  end
  let(:access_id) do
    Random.rand(1000)
  end
  let(:secret_key) do
    AuthenticatedApi.generate_secret_key
  end
  let(:headers) do
    {
        'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
        'Content-Type' => "text/plain",
        'Date' => "Mon, 23 Jan 1984 03:29:56 GMT"
    }
  end
  let(:authed_headers) do
    headers.merge(
      'Signature' => "#{hmac_signature}",
      'AccessKeyID' => "#{access_id}"
    )
  end
  let(:accounts) do
    {access_id => secret_key}
  end

  let(:app) do
    AuthenticatedApi::Server::Middleware.new(
        ->(env){
          [
              200,
              { 'Content-Type' => 'text/plain' },
              [env['api.authorized'] ? 'authorized' : 'not authorized']
          ]
        },
        accounts,
        app_options
    )
  end

  let(:app_options) do
    {}
  end

  it "sets authorized env" do
    response = post '/', {herp: "derp"}, authed_headers
    response.body.should eq 'authorized'
  end
  it "sets not authorized env" do
    response = get '/'
    response.body.should eq 'not authorized'
  end

end