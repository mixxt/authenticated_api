require 'spec_helper'
require 'digest/md5'
require 'active_resource'

describe 'Rails ActiveResource integration' do
  API_KEY_STORE = {
    'mixxt' => 'ba1ebabc2b8b3e707187cd362065cd4a' # <- checksum of the best beer
  }

  class TestResource < ActiveResource::Base
    include AuthenticatedApi::ActiveResourceExtension
    with_authenticated_api('mixxt', API_KEY_STORE['mixxt'])
    self.site = 'http://localhost/'
  end

  describe 'build the signature for' do
    before do
      FakeWeb.register_uri(:get, "http://localhost/test_resources/1.json?Signature=#{signature_get}&AccessKeyID=mixxt", :body => { test_resource: valid_params }.to_json, :status => [200, 'OK'])
      FakeWeb.register_uri(:post, "http://localhost/test_resources.json?Signature=#{signature_post}&AccessKeyID=mixxt", :body => { test_resource: valid_params }.to_json, :status => [200, 'OK'])
      FakeWeb.register_uri(:put, "http://localhost/test_resources/1.json?Signature=#{signature_put}&AccessKeyID=mixxt", :body => { test_resource: valid_params }.to_json, :status => [200, 'OK'])
      FakeWeb.register_uri(:delete, "http://localhost/test_resources/1.json?Signature=#{signature_delete}&AccessKeyID=mixxt", :body => { test_resource: valid_params }.to_json, :status => [200, 'OK'])
    end

    let(:valid_params) do
      {
        id: 1,
        name: 'Some Name'
      }
    end

    let(:signature_get) do
      CGI::escape(AuthenticatedApi::Signature.new('get', Digest::MD5.hexdigest(''), nil, 'localhost', '/test_resources/1.json', {}).sign_with(API_KEY_STORE['mixxt']))
    end
    let(:signature_post) do
      CGI::escape(AuthenticatedApi::Signature.new('post', Digest::MD5.hexdigest({ test_resource: valid_params }.to_json.to_s), 'application/json', 'localhost', '/test_resources.json', {}).sign_with(API_KEY_STORE['mixxt']))
    end
    let(:signature_put) do
      CGI::escape(AuthenticatedApi::Signature.new('put', Digest::MD5.hexdigest({ test_resource: valid_params.merge(name: 'Other Name') }.to_json.to_s), 'application/json', 'localhost', '/test_resources/1.json', {}).sign_with(API_KEY_STORE['mixxt']))
    end
    let(:signature_delete) do
      CGI::escape(AuthenticatedApi::Signature.new('delete', Digest::MD5.hexdigest(''), nil, 'localhost', '/test_resources/1.json', {}).sign_with(API_KEY_STORE['mixxt']))
    end

    it 'get' do
      TestResource.find(1)
    end
    it 'post' do
      res = TestResource.new(valid_params)
      res.save
    end
    it 'put' do
      res = TestResource.new(valid_params)
      res.instance_eval do
        @persisted = true
      end
      res.name = 'Other Name'
      res.save
    end
    it 'delete' do
      res = TestResource.new(id: 1, name: 'Some Name')
      res.instance_eval do
        @persisted = true
      end
      res.destroy
    end

  end
end
