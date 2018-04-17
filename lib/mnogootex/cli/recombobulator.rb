# frozen_string_literal: true

# :nocov:

require 'mnogootex/cfg'
require 'mnogootex/cfg/loader'
require 'mnogootex/utils'

module Mnogootex
  module CLI
    module Recombobulator
      def self.parse(*args)
        jobs, main, cfg = try_args(*args)
        jobs, main, cfg = try_link(*args) if main.nil?
        jobs, main, cfg = try_cfgs(*args) if main.nil?
        [jobs, main, cfg]
      end

      def self.try_args(*args)
        main = Pathname.new(args.last)
        return [args, nil, nil] unless main.file?
        [args[0..-2], main.realpath, default_cfg.load(main.realdirpath)]
      end

      def self.try_link(*args)
        link = Pathname.pwd.ascend.map { |p| p.join('.mnogootex.src') }.detect(&:symlink?)
        return [args, nil, nil] if link.nil?
        main = link.readlink
        [args, main.realpath, default_cfg.load(main.realdirpath)]
      end

      def self.try_cfgs(*args)
        yaml = Pathname.pwd.ascend.map { |p| p.join('.mnogootex.yml') }.detect(&:file?)
        return [args, nil, nil] if yaml.nil?
        cfg = default_cfg.load(yaml.realdirpath)
        main = yaml.realdirpath.join(cfg.fetch('main', ''))
        [args, (main.file? ? main.realpath : nil), cfg]
      end

      def self.default_cfg
        Mnogootex::Cfg::Loader.new basename: Mnogootex::Cfg::BASENAME,
                                   defaults: Mnogootex::Cfg::DEFAULTS
      end
    end
  end
end
