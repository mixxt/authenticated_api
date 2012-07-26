require 'spec_helper'

describe AuthenticatedApi::Server::Middleware do

  let(:access_id) do
    Random.rand(1000).to_s
  end
  let(:secret_key) do
    AuthenticatedApi.generate_secret_key
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
              [env['signature.valid'] ? 'authorized' : 'not authorized']
          ]
        },
        accounts,
        app_options
    )
  end
  let(:valid_signature) do
    AuthenticatedApi::Signature.new('get', 'example.org', '/', {'foo' => 'bar'}).sign_with(secret_key)
  end

  let(:app_options) do
    {}
  end

  it "sets signature.valid to true if signature is valid" do
    response = get "/?foo=bar&Signature=#{CGI::escape(valid_signature)}&AccessKeyID=#{access_id}"
    response.body.should eq 'authorized'
  end
  it "sets signature.valid to false if signature is invalid" do
    response = get '/'
    response.body.should eq 'not authorized'
  end

  context "with force: true" do
    let(:app_options) do
      {force: true}
    end

    it "returns 403" do
      response = get '/'
      response.status.should eq 403
      response.body.should eq 'Request Signature missing or invalid'
    end

  end

end