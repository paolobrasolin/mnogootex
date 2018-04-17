# frozen_string_literal: true

require 'yaml'
require 'pathname'

require 'mnogootex/utils'

module Mnogootex
  module Cfg
    class Loader < Hash
      def initialize(basename:, defaults:)
        @basename = basename
        merge! defaults
      end

      def load(pathname)
        paths = pathname.realpath.descend.
                map { |path| path.join(@basename) }.
                select(&:exist?).reject(&:zero?)
        configs = paths.map { |path| YAML.load_file path }
        configs.each { |cfg| merge! cfg }
        self
      end
    end
  end
end
