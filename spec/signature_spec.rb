require 'spec_helper'

describe AuthenticatedApi::Signature do
  let(:secret) do
    'secret'
  end
  let(:signature) do
    signature = AuthenticatedApi::Signature.new('get', 'Example.com', '/', {'something' => 'value'})
  end

  let(:signed_string) do
    AuthenticatedApi::Signature.new('get', 'Example.com', '/', {'something' => 'value'}).sign_with(secret)
  end

  it "stores method" do
    signature.method.should eq 'get'
  end
  it "stores host" do
    signature.host.should eq 'Example.com'
  end
  it "stores uri" do
    signature.uri.should eq '/'
  end
  it "stores params" do
    signature.params.should eq({'something' => 'value'})
  end
  it "builds canonicalized params" do
    signature.canonicalized_params.should eq 'something=value'
  end
  it "builds string to sign" do
    signature.string_to_sign.should eq "GET\nexample.com\n/something=value"
  end

  it "signs with secret" do
    digest = OpenSSL::Digest::Digest.new('sha256')
    ref = Base64.encode64(OpenSSL::HMAC.digest(digest, secret, "GET\nexample.com\n/something=value")).strip
    puts signature.sign_with(secret).should eq ref
  end

  describe "signature changes" do

    it "when method changes" do
      signature.method = 'PUT'
      signature.sign_with(secret).should_not eq signed_string
    end
    it "when host changes" do
      signature.host = 'google.de'
      signature.sign_with(secret).should_not eq signed_string
    end
    it "when uri changes" do
      signature.uri = '/?foo=bar'
      signature.sign_with(secret).should_not eq signed_string
    end
    it "when params changes" do
      signature.params = {'new' => 'params'}
      signature.sign_with(secret).should_not eq signed_string
    end

  end
end