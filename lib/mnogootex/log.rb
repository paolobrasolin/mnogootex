# frozen_string_literal: true

require 'mnogootex/log/level'
require 'mnogootex/log/matcher'

module Mnogootex
  # {Log} implements means to reduce log floods into filtered, color coded and human friendly summaries.
  #
  # * {Line}s are log lines.
  # * {Level}s define log levels, their priority and color coding.
  # * {Matcher}s define patterns to determine the level of log lines.
  # * {Processor}s implement all transformations.
  #
  module Log
    # Generates a hash of named levels from an array of hashes containing their attributes.
    #
    # @param levels [Array<Hash>]
    # @return [Hash<Symbol, Level>]
    def self.build_levels_hash(levels)
      levels.map do |level|
        [
          level.fetch('name'),
          Level.new(
            level.fetch('priority'),
            level.fetch('name'),
            level.fetch('color', nil)
          )
        ]
      end.to_h
    end

    # Generates an array of matchers from an array of hashes containing their attributes.
    #
    # @param matchers [Array<Hash>]
    # @return [Array<Matcher>]
    def self.build_matchers_array(matchers)
      matchers.map do |matcher|
        Matcher.new matcher.fetch('regexp'),
                    matcher.fetch('level'),
                    matcher.fetch('length')
      end
    end

    DEFAULT_LEVELS_PATH = Pathname.new(__dir__).join('configuration', 'defaults.levels.yml')
    DEFAULT_MATCHERS_PATH = Pathname.new(__dir__).join('configuration', 'defaults.matchers.yml')
    DEFAULT_LEVELS = build_levels_hash(YAML.load_file(DEFAULT_LEVELS_PATH)).freeze
    DEFAULT_MATCHERS = build_matchers_array(YAML.load_file(DEFAULT_MATCHERS_PATH)).freeze
  end
end
