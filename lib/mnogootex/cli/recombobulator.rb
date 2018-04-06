# frozen_string_literal: true

module Mnogootex
  module CLI
    module Recombobulator
      def self.parse_jobs_main(*args)
        return [[], nil] if args.empty?
        return [args[0..-2], args.last] if Pathname.new(args.last).file?
        [args, nil]
      end

      def self.parse(*args)
        jobs, mainable = parse_jobs_main(*args)
        cfg = Mnogootex::Configuration.new basename: Mnogootex::CFG_BASENAME,
                                           defaults: Mnogootex::CFG_DEFAULTS

        if !mainable.nil? && (main = Pathname.new(mainable)).file?
          main = main.realpath
          cfg.load main.dirname
        elsif (main = Pathname.new('.mnogootex.src')).symlink?
          main = main.readlink.realpath
          cfg.load main.dirname
        else
          cfg.load Pathname.pwd
          main = recombobulate_pwd cfg['main']
        end

        [jobs, main, cfg]
      end

      def self.recombobulate_pwd(mainable)
        raise DiscombobulatedError if mainable.nil?
        main = Pathname.new(mainable)
        raise DiscombobulatedError unless main.file?
        main = main.realpath
        raise DiscombobulatedError unless Pathname.pwd == main.dirname
        main
      end
    end
  end
end
