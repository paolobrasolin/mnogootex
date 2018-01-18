# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mnogootex/version"

Gem::Specification.new do |spec|
  spec.name          = "mnogootex"
  spec.version       = Mnogootex::VERSION
  spec.authors       = ["Paolo Brasolin"]
  spec.email         = ["paolo.brasolin@gmail.com"]

  spec.summary       = %q{Mnogootex (многоꙮтех) is a device to handle the compilation of TeX sources with different preambles at one time.}
  spec.description   = %q{Mnogootex (многоꙮтех) is a device to handle the compilation of TeX sources with different preambles at one time. This avoids wasting time when you have to submit a paper to journals using outdated or crummy document classes.}
  spec.homepage      = "https://github.com/tetrapharmakon/mnogootex"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|mwe|mnogootex_classes)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "colorize"
  spec.add_dependency "thor"
end
