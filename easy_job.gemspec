# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'easy_job/version'

Gem::Specification.new do |spec|
  spec.name          = 'easy_job'
  spec.version       = EasyJob::VERSION
  spec.authors       = ['Ondřej Moravčík']
  spec.email         = ['moravcik.ondrej@gmail.com']

  spec.summary       = %q{Asynchronous job for easyproject}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/ondra-m/easy_job'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # spec.bindir        = 'exe'
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'concurrent-ruby'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
