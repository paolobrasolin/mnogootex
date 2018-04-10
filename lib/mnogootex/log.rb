# frozen_string_literal: true
# :nocov:

require 'mnogootex/log/level'
require 'mnogootex/log/matcher'

require 'pathname'
require 'yaml'

module Mnogootex
  # {Log} implements means to reduce log floods into filtered, color coded and human friendly summaries.
  #
  # * {Line}s are log lines.
  # * {Level}s define log levels, their priority and color coding.
  # * {Matcher}s define patterns to determine the level of log lines.
  # * {Processor}s implement all transformations.
  #
  module Log
    DEFAULT_LEVELS_PATH = Pathname.new(__dir__).join('log', 'levels.yml')
    DEFAULT_MATCHERS_PATH = Pathname.new(__dir__).join('log', 'matchers.yml')
    DEFAULT_LEVELS = YAML.load_file(DEFAULT_LEVELS_PATH).map { |l| [l.name, l] }.to_h.freeze
    DEFAULT_MATCHERS = YAML.load_file(DEFAULT_MATCHERS_PATH).freeze
  end
end
