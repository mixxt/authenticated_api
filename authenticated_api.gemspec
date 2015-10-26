# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

require 'authenticated_api/version'

Gem::Specification.new do |s|
  s.name = %q{authenticated_api}
  s.summary = %q{Simple HMAC authentication for your APIs}
  s.description = %q{Based on api-auth gem}
  s.homepage = %q{http://github.com/mixxt/authenticated_api}
  s.version = AuthenticatedApi::VERSION
  s.authors = ['Christoph Geschwind', 'Axel Wahlen', 'Mauricio Gomes']
  s.email = 'christoph@mixxt.net'

  s.add_dependency 'rack'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'amatch'
  s.add_development_dependency 'rest-client'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'activeresource'
  s.add_development_dependency 'multipart-post'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
