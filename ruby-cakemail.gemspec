# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-cakemail"
  spec.version       = Ruby::Cakemail::VERSION
  spec.authors       = ["Nicolas Gonzalez"]
  spec.email         = ["nicolasgonzalez180@gmail.com"]
  spec.summary       = %q{Ruby CakeMail}
  spec.description   = %q{Ruby CakeMail}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "crypt19-rb"
  spec.add_runtime_dependency "xml-simple"

end
