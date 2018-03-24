# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec' do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  watch(dsl.rspec.spec_helper) { dsl.rspec.spec_dir }
  watch(dsl.rspec.spec_files)

  # Ruby files
  dsl.watch_spec_files_for(dsl.ruby.lib_files)
end

# TODO: refactor the following into a new version of guard-mutant

require 'mutant'
require 'dry/inflector'
require 'guard/compat/plugin'

module ::Guard # :: mandatory for inline guards
  class Mutant < Plugin
    def initialize(options = {})
      opts = options.dup
      @my_option = opts.delete(:my_special_option)
      super(opts) # important to call + avoid passing options Guard doesn't understand
    end

    def run_all
      # TODO
    end

    def run_on_modifications(paths)
      inflector = Dry::Inflector.new
      subjects = paths.map do |path|
        match = path.match(/(?:spec|lib)\/(.*?)(?:_spec)?.rb/).captures.first
        inflector.camelize match
      end
      succesful = ::Mutant::CLI.run(%w(--use rspec --fail-fast) + subjects)
      throw :task_has_failed unless succesful
      self
    end
  end
end

guard :mutant do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  watch(dsl.rspec.spec_helper) { dsl.rspec.spec_dir }
  watch(dsl.rspec.spec_files)

  # Ruby files
  dsl.watch_spec_files_for(dsl.ruby.lib_files)
end

