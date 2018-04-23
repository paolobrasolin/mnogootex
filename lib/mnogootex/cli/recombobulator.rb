# frozen_string_literal: true

# :nocov:

require 'mnogootex/cfg'
require 'mnogootex/core_ext'

module Mnogootex
  module CLI
    module Recombobulator
      def self.parse(*args)
        try_args(*args) || try_link(*args) || try_cfgs(*args)
      end

      def self.try_args(*args)
        main = Pathname.new(args.fetch(-1, ''))
        return unless main.file?

        main = main.realpath
        cfg = Mnogootex::Cfg.load_descending(pathname: main.dirname, basename: Mnogootex::Cfg::BASENAME)
        jobs = args[0..-2].unless(&:empty?)

        [jobs, main, cfg]
      end

      def self.try_link(*args)
        link = Pathname.pwd.ascend.map { |p| p.join('.mnogootex.src') }.detect(&:symlink?)
        return if link.nil?

        main = link.readlink.realpath
        cfg = Mnogootex::Cfg.load_descending(pathname: main.dirname, basename: Mnogootex::Cfg::BASENAME)
        jobs = args

        [jobs, main, cfg]
      end

      def self.try_cfgs(*args)
        yaml = Pathname.pwd.ascend.map { |p| p.join('.mnogootex.yml') }.detect(&:file?)
        return if yaml.nil?

        cfg = Mnogootex::Cfg.load_descending(pathname: yaml.dirname, basename: Mnogootex::Cfg::BASENAME)
        main = yaml.dirname.join(cfg.fetch('main', '')).if(&:file?)&.realpath
        jobs = args

        [jobs, main, cfg]
      end
    end
  end
end
