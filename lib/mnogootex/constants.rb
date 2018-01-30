# frozen_string_literal: true

require 'yaml'
require 'pathname'

module Mnogootex
  CFG_PATH = Pathname.new(__dir__).join('configuration')

  CFG_DEFAULTS =
    YAML.load_file(CFG_PATH.join('defaults.yml')).
    merge!('matchers' => YAML.load_file(CFG_PATH.join('defaults.matchers.yml')))

  CFG_BASENAME = '.mnogootex.yml'
end
