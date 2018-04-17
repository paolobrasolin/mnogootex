# frozen_string_literal: true

# :nocov:

require 'yaml'
require 'pathname'

module Mnogootex
  module Cfg
    DEFAULTS_PATH = Pathname.new(__dir__).join('cfg')
    DEFAULTS = YAML.load_file(DEFAULTS_PATH.join('defaults.yml'))
    BASENAME = '.mnogootex.yml'
  end
end
