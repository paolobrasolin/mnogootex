# frozen_string_literal: true

require 'yaml'
require 'pathname'

module Mnogootex
  module Cfg
    BASENAME = '.mnogootexrc'
    DEFAULTS = {
      'jobs' => [],
      'spinner' => '⣾⣽⣻⢿⡿⣟⣯⣷',
      'work_path' => nil,
    }.freeze

    def self.load_descending(pathname:, basename:)
      pathname.realpath.descend.
        map { |path| path.join(basename) }.
        select(&:exist?).reject(&:zero?).
        map { |path| YAML.load_file(path) }.
        reduce(&:merge!)
    end

    def self.recombobulate(*args)
      try_args(*args) || try_link(*args) || try_cfgs(*args)
    end

    class << self
      private

      def split_jobs_and_flags(args)
        # TODO: some kind of validation?
        flags = args.drop_while { |arg| !arg.start_with?('-') }
        jobs = args.take_while { |arg| !arg.start_with?('-') }
        [(jobs unless jobs.empty?), (flags unless flags.empty?)]
      end

      def try_args(*args)
        main = Pathname.new(args.fetch(-1, ''))
        return unless main.file?

        main = main.realpath
        cfg = load_descending(pathname: main.dirname, basename: BASENAME)
        jobs, flags = split_jobs_and_flags(args[0..-2])

        [jobs, flags, main, cfg]
      end

      def try_link(*args)
        link = Pathname.pwd.ascend.map { |p| p.join('.mnogootex.src') }.detect(&:symlink?)
        return if link.nil?

        main = link.readlink.realpath
        cfg = load_descending(pathname: main.dirname, basename: BASENAME)
        jobs, flags = split_jobs_and_flags(args)

        [jobs, flags, main, cfg]
      end

      def try_cfgs(*args)
        yaml = Pathname.pwd.ascend.map { |p| p.join('.mnogootexrc') }.detect(&:file?)
        return if yaml.nil?

        cfg = load_descending(pathname: yaml.dirname, basename: BASENAME)
        main = yaml.dirname.join(cfg.fetch('main', ''))
        main = main.file? ? main.realpath : nil
        jobs, flags = split_jobs_and_flags(args)

        [jobs, flags, main, cfg]
      end
    end
  end
end
