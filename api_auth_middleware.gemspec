# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = %q{api_auth_middleware}
  s.summary = %q{Middleware for: Simple HMAC authentication for your APIs}
  s.description = %q{Based on api-auth gem}
  s.homepage = %q{http://github.com/1st8/api_auth_middleware}
  s.version = File.read(File.join(File.dirname(__FILE__), 'VERSION'))
  s.authors = ["Mauricio Gomes", "Christoph Geschwind"]
  s.email = "christoph@mixxt.net"

  s.add_dependency "rack"

  s.add_development_dependency "rack-test"
  s.add_development_dependency "rspec"
  s.add_development_dependency "amatch"
  s.add_development_dependency "activesupport"
  s.add_development_dependency "rest-client"
  s.add_development_dependency "curb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
