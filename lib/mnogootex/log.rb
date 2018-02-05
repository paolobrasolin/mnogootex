# frozen_string_literal: true

require 'mnogootex/log/level'
require 'mnogootex/log/matcher'

module Mnogootex
  module Log
    # NOTE: we're dealing with these defaults to effortlessly allow for configurability in some future release
    LEVELS_PATH = Pathname.new(__dir__).join('configuration', 'defaults.levels.yml')
    MATCHERS_PATH = Pathname.new(__dir__).join('configuration', 'defaults.matchers.yml')

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

    def self.build_matchers_array(matchers)
      matchers.map do |matcher|
        Matcher.new matcher.fetch('regexp'),
                    matcher.fetch('level'),
                    matcher.fetch('length')
      end
    end

    LEVELS = build_levels_hash(YAML.load_file(LEVELS_PATH)).freeze
    MATCHERS = build_matchers_array(YAML.load_file(MATCHERS_PATH)).freeze
  end
end
