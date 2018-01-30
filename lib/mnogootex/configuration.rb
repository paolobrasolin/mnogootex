# frozen_string_literal: true

require 'yaml'
require 'pathname'

module Mnogootex
  class Configuration < Hash
    def initialize(basename:, defaults: {})
      @paths = []
      @basename = basename
      @defaults = defaults
      merge! @defaults
    end

    def load(pathname = Pathname.pwd)
      scan_cfg Pathname(pathname)
      filter_cfg
      merge! load_cfg
      self
    end

    private

    def scan_cfg(pathname)
      @paths << pathname.join(@basename)
      return if pathname.root?
      scan_cfg pathname.parent
    end

    def filter_cfg
      @paths.
        select!(&:readable?).
        reject!(&:zero?)
    end

    def load_cfg
      @paths.
        reverse.
        map { |pathname| YAML.load_file pathname }.
        inject(&:merge!) # TODO: deep merge
    end
  end
end
