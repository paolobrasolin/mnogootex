# frozen_string_literal: true

# :nocov:

require 'thor'
require 'pathname'

require 'mnogootex/utils'
require 'mnogootex/job/warden'
require 'mnogootex/job/porter'
require 'mnogootex/cli/recombobulator'

module Mnogootex
  module CLI
    class Application < Thor
      IS_MNOGOO = (ENV['IS_MNOGOO'] == 'true').freeze

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
        # NOTE: this is a tad slow - using shell would improve that
        tmp_dir = Pathname.new(Dir.tmpdir).join('mnogootex')
        tmp_dir_size = Mnogootex::Utils.humanize_bytes Mnogootex::Utils.dir_size(tmp_dir)
        print "Freeing up #{tmp_dir_size}... "
        FileUtils.rm_r tmp_dir, secure: true if tmp_dir.directory?
        puts 'Done.'
      end

      desc 'go [JOBS ...] [MAIN]',
           'Run compilation JOBS for MAIN document'
      def go(*args)
        _, main, opts = Mnogootex::CLI::Recombobulator.parse(*args)
        Mnogootex::Job::Warden.new(source: main, configuration: opts).start
      end

      desc 'dir [JOBS ...] [MAIN]',
           'Print target dirs relative to JOBS for MAIN document'
      def dir(*args)
        jobs, main, = Mnogootex::CLI::Recombobulator.parse(*args)

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
        jobs, main, = Mnogootex::CLI::Recombobulator.parse(*args)

        if jobs.empty?
          puts Dir.glob(main.dirname.join('*.pdf')).first
        else
          jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main }
          jobs.map! { |porter| porter.target_path.sub_ext('.pdf') }
          puts jobs
        end
      end
    end
  end
end
