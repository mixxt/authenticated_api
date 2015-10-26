require 'spec_helper'
require 'digest/md5'

describe AuthenticatedApi::Server do
  let(:secret) do
    'secret'
  end
  let!(:valid_signature) do
    AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest('such prosa'), 'text/plain', 'example.org', '/', { 'foo' => 'bar' }).sign_with(secret)
  end
  let!(:invalid_signature) do
    AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest(''), nil, 'example.org', '/', { 'foo' => 'bar' }).sign_with('I dont know the secret')
  end
  let!(:valid_signature_with_body) do
    AuthenticatedApi::Signature.new('post', Digest::MD5.hexdigest('THE BODY'), 'text/plain', 'example.org', '/', {}).sign_with(secret)
  end
  let!(:invalid_signature_with_body) do
    AuthenticatedApi::Signature.new('post', Digest::MD5.hexdigest('THE BODY'), 'text/plain', 'example.org', '/', {}).sign_with('I dont know the secret')
  end
  let(:valid_request) do
    Rack::Request.new(Rack::MockRequest.env_for("/?foo=bar&Signature=#{CGI::escape(valid_signature)}", { input: 'such prosa', 'CONTENT_TYPE' => 'text/plain' }))
  end
  let(:invalid_request) do
    Rack::Request.new(Rack::MockRequest.env_for("/?foo=bar&Signature=#{CGI::escape(invalid_signature)}"))
  end
  let(:valid_request_with_body) do
    Rack::Request.new(Rack::MockRequest.env_for("/?Signature=#{CGI::escape(valid_signature_with_body)}", { method: :post, input: 'THE BODY', 'CONTENT_TYPE' => 'text/plain' }))
  end
  let(:invalid_request_with_body) do
    Rack::Request.new(Rack::MockRequest.env_for("/?Signature=#{CGI::escape(invalid_signature_with_body)}", { method: :post, input: 'THE BODY', 'CONTENT_TYPE' => 'text/plain' }))
  end

  it 'should accept signature of valid request' do
    AuthenticatedApi::Server.valid_signature?(valid_request, secret).should be_true
  end
  it 'should not accept signature of invalid request' do
    AuthenticatedApi::Server.valid_signature?(invalid_request, secret).should be_false
  end

  it 'should accept signature of valid request with body' do
    AuthenticatedApi::Server.valid_signature?(valid_request_with_body, secret).should be_true
  end

  it 'should not accept signature of invalid request with body' do
    AuthenticatedApi::Server.valid_signature?(invalid_request_with_body, secret).should be_false
  end

  context 'with binary multipart/form-data' do
    let(:request) do
      Net::HTTP::Post::Multipart.new('/', { file: UploadIO.new('./spec/fixtures/test-image.png', 'image/png'), another_param: 'another value' })
    end

    let(:signature) do
      request.body_stream.rewind
      signature = AuthenticatedApi::Signature.new(request.method, Digest::MD5.hexdigest(request.body_stream.read), request.content_type, 'example.org', '/', {}).sign_with(secret)
      request.body_stream.rewind
      signature
    end

    let(:mocked_request) do
      Rack::Request.new(
        Rack::MockRequest.env_for(
          "/?Signature=#{CGI::escape(signature)}",
          {
            method: :post,
            'CONTENT_TYPE' => 'multipart/form-data'
          }
        ).merge('rack.input' => request.body_stream)
      )
    end

    it 'should accept signature of valid binary request' do
      expect(AuthenticatedApi::Server.valid_signature?(mocked_request, secret)).to be_true
    end
  end
end