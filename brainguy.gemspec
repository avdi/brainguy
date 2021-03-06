# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brainguy/version'

Gem::Specification.new do |spec|
  spec.name          = "brainguy"
  spec.version       = Brainguy::VERSION
  spec.authors       = ["Avdi Grimm"]
  spec.email         = ["avdi@avdi.org"]
  spec.summary       = %q{An Observer pattern library}
  spec.description   = %q{A somewhat fancy observer pattern library with
features like named events and scoped subscriptions.}
  spec.homepage      = "https://github.com/avdi/brainguy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "yard", "~> 0.8.7"
  spec.add_development_dependency "seeing_is_believing", "~> 2.2"
end
