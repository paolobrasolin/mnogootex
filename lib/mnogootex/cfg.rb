# frozen_string_literal: true

# :nocov:

require 'yaml'
require 'pathname'

module Mnogootex
  module Cfg
    BASENAME = '.mnogootex.yml'
    DEFAULTS = YAML.load_file(Pathname.new(__dir__).join(BASENAME))

    def self.load_descending(pathname:, basename:)
      pathname.realpath.descend.
        map { |path| path.join(basename) }.
        select(&:exist?).reject(&:zero?).
        map { |path| YAML.load_file(path) }.
        reduce(&:merge!)
    end
  end
end
