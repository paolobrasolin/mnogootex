# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mnogootex/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = 'mnogootex'
  spec.version       = Mnogootex::VERSION
  spec.authors       = ['Paolo Brasolin']
  spec.email         = ['paolo.brasolin@gmail.com']

  spec.summary       = <<~SUMMARY.tr("\n", ' ').squeeze(' ').strip
    Mnogootex (многоꙮтех) is a device to handle the compilation of
    TeX sources with different preambles at one time.
  SUMMARY

  spec.description = <<~DESCRIPTION.tr("\n", ' ').squeeze(' ').strip
    Mnogootex (многоꙮтех) is a device to handle the compilation of
    TeX sources with different preambles at one time. This avoids
    wasting time when you have to submit a paper to journals using
    outdated or crummy document classes.
  DESCRIPTION

  spec.homepage      = 'https://github.com/tetrapharmakon/mnogootex'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|mwe)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16.1'
  spec.add_development_dependency 'rake', '~> 10.4.2'
  spec.add_development_dependency 'rspec', '~> 3.6.0'
  spec.add_development_dependency 'rubocop', '~> 0.52.1'

  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'thor', '~> 0.20.0'
end
