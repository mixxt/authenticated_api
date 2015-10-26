require 'spec_helper'
require 'digest/md5'

describe AuthenticatedApi::Signature do
  let(:secret) do
    'secret'
  end

  shared_examples 'store signature properties' do
    it 'stores method' do
      signature.method.should eq 'get'
    end
    it 'stores host' do
      signature.host.should eq 'Example.com'
    end
    it 'stores uri' do
      signature.uri.should eq '/'
    end
    it 'stores params' do
      signature.params.should eq({ 'something' => 'value' })
    end
    it 'builds canonicalized params' do
      signature.canonicalized_params.should eq 'something=value'
    end

    describe 'signature changes' do
      it 'when method changes' do
        signature.method = 'PUT'
        signature.sign_with(secret).should_not eq signed_string
      end
      it 'when host changes' do
        signature.host = 'google.de'
        signature.sign_with(secret).should_not eq signed_string
      end
      it 'when uri changes' do
        signature.uri = '/?foo=bar'
        signature.sign_with(secret).should_not eq signed_string
      end
      it 'when params changes' do
        signature.params = { 'new' => 'params' }
        signature.sign_with(secret).should_not eq signed_string
      end
    end
  end

  context 'without body' do
    let(:signature) do
      AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest(''), nil, 'Example.com', '/', { 'something' => 'value' })
    end
    let(:signed_string) do
      AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest(''), nil, 'Example.com', '/', { 'something' => 'value' }).sign_with(secret)
    end
    include_examples 'store signature properties'
    it 'stores body_md5' do
      signature.body_md5.should eq Digest::MD5.hexdigest('')
    end
    it 'stores content_type' do
      signature.content_type.should eq nil
    end
    it 'builds string to sign' do
      signature.string_to_sign.should eq "GET\nexample.com\n/something=value"
    end
    it 'signs with secret' do
      digest = OpenSSL::Digest::Digest.new('sha256')
      ref = Base64.encode64(OpenSSL::HMAC.digest(digest, secret, "GET\nexample.com\n/something=value")).strip
      signature.sign_with(secret).should eq ref
    end
  end

  context 'with body' do
    let(:signature) do
      AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest('THE BODY'), 'text/plain', 'Example.com', '/', { 'something' => 'value' })
    end
    let(:signed_string) do
      AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest('THE BODY'), 'text/plain', 'Example.com', '/', { 'something' => 'value' }).sign_with(secret)
    end
    include_examples 'store signature properties'
    it 'stores body_md5' do
      signature.body_md5.should eq Digest::MD5.hexdigest('THE BODY')
    end
    it 'stores content_type' do
      signature.content_type.should eq 'text/plain'
    end
    it 'builds string to sign' do
      signature.string_to_sign.should eq "GET\n#{Digest::MD5.hexdigest('THE BODY')}\ntext/plain\nexample.com\n/something=value"
    end
    it 'signs with secret' do
      digest = OpenSSL::Digest::Digest.new('sha256')
      ref = Base64.encode64(OpenSSL::HMAC.digest(digest, secret, "GET\n#{Digest::MD5.hexdigest('THE BODY')}\ntext/plain\nexample.com\n/something=value")).strip
      signature.sign_with(secret).should eq ref
    end
    describe 'signature changes' do
      it 'when body_md5 changes' do
        signature.body_md5 = Digest::MD5.hexdigest('WRONG BODY')
        signature.sign_with(secret).should_not eq signed_string
      end
      it 'when content_type changes' do
        signature.content_type = 'application/json'
        signature.sign_with(secret).should_not eq signed_string
      end
    end
  end

  context 'with stream body' do
    let(:request) do
      Net::HTTP::Post::Multipart.new('/', {
        file: UploadIO.new('./spec/fixtures/test-image.png', 'image/png', 'image.png'),
        another_param: 'other param'
      })
    end

    let(:signature) do
      request.body_stream.rewind
      signature = AuthenticatedApi::Signature.new(request.method, Digest::MD5.hexdigest(request.body_stream.read), request.content_type, 'example.com', request.path, { 'something' => 'value' })
      request.body_stream.rewind
      signature
    end

    let(:signed_string) do
      signature.sign_with(secret)
    end

    it 'stores body_md5' do
      request.body_stream.rewind
      expect(signature.body_md5).to eq Digest::MD5.hexdigest(request.body_stream.read)
      request.body_stream.rewind
    end

    it 'stores content_type' do
      signature.content_type.should eq request.content_type
    end

    it 'builds string to sign' do
      signature.string_to_sign.should eq "POST\n#{signature.body_md5}\nmultipart/form-data\nexample.com\n/something=value"
    end

    it 'signs with secret' do
      digest = OpenSSL::Digest::Digest.new('sha256')
      ref = Base64.encode64(OpenSSL::HMAC.digest(digest, secret, signature.string_to_sign)).strip
      signature.sign_with(secret).should eq ref
    end
  end
end
