# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'isostatic/version'

Gem::Specification.new do |spec|
  spec.name          = "isostatic-scraper"
  spec.version       = Isostatic::VERSION
  spec.authors       = ["Cristian Rasch"]
  spec.email         = ["cristianrasch@fastmail.fm"]
  spec.summary       = %q{bearing-solutions.isostatic.com item information scraper}
  spec.homepage      = "https://github.com/MROSupply/isostatic-scraper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mechanize"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
