# frozen_string_literal: true

require 'thor'
require 'pathname'

require 'mnogootex/constants'
require 'mnogootex/utils'
require 'mnogootex/errors'
require 'mnogootex/configuration'
require 'mnogootex/job/warden'
require 'mnogootex/job/porter'

module Mnogootex
  module CLI
    class Application < Thor
      IS_MNOGOO = ENV['IS_MNOGOO'] == 'true'

      def self.basename
        IS_MNOGOO ? 'mnogoo' : super
      end

      desc 'cd [JOB] [MAIN]',
          'Check into target dir relative to JOB for MAIN document'
      def cd(*args); end

      desc 'open [JOBS ...] [MAIN]',
          'Open target PDFs relative to JOBS for MAIN document'
      def open(*args); end

      remove_command :cd, :open unless IS_MNOGOO

      desc 'mnogoo',
          'Print path of the shell wrapper script mnogoo'
      def mnogoo
        puts Pathname.new(__dir__).join('cli', 'mnogoo.sh')
      end

      desc 'clobber',
          'Clean up all temporary files'
      def clobber
        tmp_dir = Pathname.new(Dir.tmpdir).join('mnogootex')
        tmp_dir_size = Mnogootex::Utils.humanize_bytes Mnogootex::Utils.dir_size(tmp_dir)
        print "Freeing up #{tmp_dir_size}... "
        FileUtils.rm_r tmp_dir, secure: true if tmp_dir.directory?
        puts 'Done.'
      end

      desc 'go [JOBS ...] [MAIN]',
          'Run compilation JOBS for MAIN document'
      def go(*args)
        _, main, opts = recombobulate(*args)
        Mnogootex::Job::Warden.new(source: main, configuration: opts).start
      end

      desc 'dir [JOBS ...] [MAIN]',
          'Print target dirs relative to JOBS for MAIN document'
      def dir(*args)
        jobs, main, = recombobulate(*args)

        if jobs.empty?
          puts main.dirname
        else
          jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main }
          jobs.map!(&:target_dir)
          puts jobs
        end
      end

      desc 'pdf [JOBS ...] [MAIN]',
          'Print pdf paths relative to JOBS for MAIN document'
      def pdf(*args)
        jobs, main, = recombobulate(*args)

        if jobs.empty?
          puts Dir.glob(main.dirname.join('*.pdf')).first
        else
          jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main }
          jobs.map! { |porter| porter.output_path.sub_ext('.pdf') }
          puts jobs
        end
      end

      private

      def parse_jobs_main(*args)
        return [[], nil] if args.empty?
        return [args[0..-2], args.last] if Pathname.new(args.last).file?
        [args, nil]
      end

      def recombobulate(*args)
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

      def recombobulate_pwd(mainable)
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
