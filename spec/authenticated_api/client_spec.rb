require 'spec_helper'

describe AuthenticatedApi::Client do

  describe "signing requests" do

    def hmac(secret_key, request)
      canonical_string = AuthenticatedApi::Client::Headers.new(request).canonical_string
      digest = OpenSSL::Digest::Digest.new('sha1')
      AuthenticatedApi.b64_encode(OpenSSL::HMAC.digest(digest, secret_key, canonical_string))
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

    describe "with Net::HTTP" do

      let(:request) do
        Net::HTTP::Put.new("/resource.xml?foo=bar&bar=foo", headers)
      end
      
      let(:signed_request) do
        AuthenticatedApi::Client.sign!(request, access_id, secret_key)
      end

      it "should return a Net::HTTP object after signing it" do
        AuthenticatedApi::Client.sign!(request, access_id, secret_key).class.to_s.should match("Net::HTTP")
      end

      it "should sign the request" do
        signed_request['Authorization'].should == "APIAuth #{access_id}:#{hmac(secret_key, request)}"
      end

    end

    describe "with RestClient" do

      let(:request) do
        RestClient::Request.new(:url => "/resource.xml?foo=bar&bar=foo",
          :headers => headers,
          :method => :put
        )
      end
      let(:signed_request) do
        AuthenticatedApi::Client.sign!(request, access_id, secret_key)
      end

      it "should return a RestClient object after signing it" do
        AuthenticatedApi::Client.sign!(request, access_id, secret_key).class.to_s.should match("RestClient")
      end

      it "should sign the request" do
        signed_request.headers['Authorization'].should == "APIAuth #{access_id}:#{hmac(secret_key, request)}"
      end

    end

    describe "with Curb" do
      let(:request) do
        Curl::Easy.new("/resource.xml?foo=bar&bar=foo") do |curl|
          curl.headers = headers
        end
      end
      let(:signed_request) do
        AuthenticatedApi::Client.sign!(request, access_id, secret_key)
      end

      it "should return a Curl::Easy object after signing it" do
        AuthenticatedApi::Client.sign!(request, access_id, secret_key).class.to_s.should match("Curl::Easy")
      end

      it "should sign the request" do
        signed_request.headers['Authorization'].should == "APIAuth #{access_id}:#{hmac(secret_key, request)}"
      end

    end

  end

end