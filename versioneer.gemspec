# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'versioneer'

Gem::Specification.new do |spec|
  spec.name          = 'versioneer'
  spec.version       = Versioneer::GEM_VERSION
  spec.authors       = ['BinaryBabel OSS']
  spec.email         = ['oss@binarybabel.net']
  spec.homepage      = 'https://github.com/binarybabel/gem-versioneer'

  spec.summary       = 'Dynamic project versioning (alpha/beta/rc) based on commits since last Git tag.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files        += ['version.lock']
  spec.bindir        = 'bin'
  spec.executables   = ['versioneer']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0'
end
