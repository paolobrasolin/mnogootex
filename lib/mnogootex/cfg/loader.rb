# frozen_string_literal: true

require 'yaml'
require 'pathname'

module Mnogootex
  module Cfg
    class Loader < Hash
      def initialize(basename:, defaults:)
        @paths = []
        @basename = basename
        merge! defaults
      end

      def load(pathname)
        scan_cfg pathname.realpath
        filter_cfg
        merge! load_cfg
      end

      private

      def scan_cfg(pathname)
        @paths << pathname.join(@basename)
        return if pathname.root?
        scan_cfg pathname.parent
      end

      def filter_cfg
        @paths.select!(&:readable?)
        @paths.reject!(&:zero?)
      end

      def load_cfg
        @paths.reverse!
        @paths.map! { |pathname| YAML.load_file pathname }
        @paths.inject(&:merge!) # TODO: deep merge
      end
    end
  end
end
