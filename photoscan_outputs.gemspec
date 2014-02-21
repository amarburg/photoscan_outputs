# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'photoscan_outputs/version'

Gem::Specification.new do |spec|
  spec.name          = "photoscan_outputs"
  spec.version       = PhotoscanOutputs::VERSION
  spec.authors       = ["Aaron Marburg"]
  spec.email         = ["amarburg@notetofutureself.org"]
  spec.summary       = %q{A Ruby Gem to parse export file formats from Photoscan.}
  spec.homepage      = "http://github.com/amarburg/rb_photoscan_outputs"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "trollop"

  spec.add_dependency "ox"
end
