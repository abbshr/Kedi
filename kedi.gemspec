# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kedi/version'

Gem::Specification.new do |spec|
  spec.name          = "kedi"
  spec.version       = Kedi::VERSION
  spec.authors       = ["ran"]
  spec.email         = ["abbshr@outlook.com"]

  spec.summary       = %q{a stream process platform}
  spec.description   = %q{a simple and elegant stream process framework allow manipulating with DSL}
  spec.homepage      = "https://github.com/abbshr/Kedi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"

  spec.add_dependency "rack"
  spec.add_dependency "puma"
  spec.add_dependency "grape"
  spec.add_dependency "logging"
  spec.add_dependency "require_all"
  spec.add_dependency "redis-object"
  spec.add_dependency "awesome_print"
  spec.add_dependency "activesupport"
end
