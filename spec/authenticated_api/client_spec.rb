require 'spec_helper'
require 'active_support/core_ext/hash/slice'
require 'digest/md5'

describe AuthenticatedApi::Client do

  describe 'signing requests' do
    before do
      FakeWeb.register_uri(:get, "http://localhost:4000/?foo=bar&Signature=#{signature}&AccessKeyID=#{access_id}", :body => 'Well signed', :status => [200, 'OK'])
    end

    let(:access_id) do
      Random.rand(1000)
    end
    let(:secret_key) do
      SecureRandom.base64(16)
    end

    let(:signature) do
      CGI::escape(AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest(''), nil, 'localhost', '/', { 'foo' => 'bar' }).sign_with(secret_key))
    end

    let(:client) do
      AuthenticatedApi::Client.new('localhost', 4000, access_id, secret_key)
    end

    it 'signs request before sending' do
      client.request(Net::HTTP::Get.new('/?foo=bar'))
      FakeWeb.last_request.path.should include "Signature=#{signature}"
      FakeWeb.last_request.path.should include "AccessKeyID=#{access_id}"
    end

    it 'returns response' do
      response = client.request(Net::HTTP::Get.new("/?foo=bar"))
      response.should be_a Net::HTTPOK
      response.body.should eq 'Well signed'
    end

    context 'empty query' do
      before do
        FakeWeb.register_uri(:get, "http://localhost:4000/?Signature=#{signature}&AccessKeyID=#{access_id}", :body => 'Well signed', :status => [200, 'OK'])
      end

      let(:signature) do
        CGI::escape(AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest(''), nil, 'localhost', '/', {}).sign_with(secret_key))
      end

      it 'generates query' do
        response = client.request(Net::HTTP::Get.new('/'))
        response.should be_a Net::HTTPOK
        FakeWeb.last_request.path.should eq "/?Signature=#{signature}&AccessKeyID=#{access_id}"
      end
    end

    context 'with body' do
      before do
        FakeWeb.register_uri(:post, "http://localhost:4000/?Signature=#{signature}&AccessKeyID=#{access_id}", :body => 'Well signed', :status => [200, 'OK'])
      end

      let(:signature) do
        CGI::escape(AuthenticatedApi::Signature.new('post', Digest::MD5.hexdigest('THE BODY'), 'text/plain', 'localhost', '/', {}).sign_with(secret_key))
      end

      it 'generates query' do
        post = Net::HTTP::Post.new('/')
        post.content_type = 'text/plain'
        post.body = 'THE BODY'
        response = client.request(post)
        response.should be_a Net::HTTPOK
        FakeWeb.last_request.path.should eq "/?Signature=#{signature}&AccessKeyID=#{access_id}"
      end
    end

    context 'with body stream' do
      before do
        FakeWeb.register_uri(:post, "http://localhost:4000/?Signature=#{signature}&AccessKeyID=#{access_id}", :body => 'Well signed', :status => [200, 'OK'])
      end

      let(:signature) do
        CGI::escape(AuthenticatedApi::Signature.new('post', Digest::MD5.hexdigest('THE BODY'), 'text/plain', 'localhost', '/', {}).sign_with(secret_key))
      end

      it 'generates query' do
        post = Net::HTTP::Post.new('/')
        post.content_type = 'text/plain'
        post.body_stream = StringIO.new('THE BODY')
        response = client.request(post)
        response.should be_a Net::HTTPOK
        FakeWeb.last_request.path.should eq "/?Signature=#{signature}&AccessKeyID=#{access_id}"
      end
    end
  end

end