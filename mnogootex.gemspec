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
    Многоꙮтех (mnogootex) is a utility that parallelizes compilation
    of a LaTeX document using different classes and offers a
    meaningfully filtered output.
  SUMMARY

  spec.description = <<~DESCRIPTION.tr("\n", ' ').squeeze(' ').strip
    Многоꙮтех (mnogootex) is a utility that parallelizes compilation
    of a LaTeX document using different classes and offers a
    meaningfully filtered output.
    The motivating use case is maintaining a single preamble while
    submitting a paper to many journals using their outdated or crummy
    document classes.
  DESCRIPTION

  spec.homepage      = 'https://github.com/tetrapharmakon/mnogootex'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|mwe)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16.1'
  spec.add_development_dependency 'byebug', '~> 10.0.0'
  spec.add_development_dependency 'dry-inflector', '~> 0.1.1'
  spec.add_development_dependency 'guard', '~> 2.14.2'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'mutant', '~> 0.8.14'
  spec.add_development_dependency 'mutant-rspec', '~> 0.8.14'
  spec.add_development_dependency 'rake', '~> 10.4.2'
  spec.add_development_dependency 'rspec', '~> 3.6.0'
  spec.add_development_dependency 'rubocop', '~> 0.52.1'
  spec.add_development_dependency 'simplecov', '~> 0.15.1'
  spec.add_development_dependency 'yard', '~> 0.9.12'

  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'thor', '~> 0.20.0'
end
