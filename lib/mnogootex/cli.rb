# frozen_string_literal: true

require 'thor'
require 'pathname'

require 'mnogootex/utils'
require 'mnogootex/job/warden'
require 'mnogootex/job/porter'
require 'mnogootex/cfg'

module Mnogootex
  class CLI < Thor
    desc 'open [JOB ...] [MAIN]',
         'Open PDF of each (or every) JOB for MAIN (or inferred) document'
    def open(*args);
      raise "TODO: implement this w/ latexmk -pv"
    end

    desc 'clobber',
         'Clean up all temporary files'
    def clobber
      # NOTE: this is a tad slow - using shell would improve that
      # TODO: this does not account for custom work_path
      tmp_dir = Pathname.new(Dir.tmpdir).join('mnogootex')
      tmp_dir_size = Mnogootex::Utils.humanize_bytes Mnogootex::Utils.dir_size(tmp_dir)
      print "Freeing up #{tmp_dir_size}... "
      FileUtils.rm_r tmp_dir, secure: true if tmp_dir.directory?
      puts 'Done.'
    end

    desc 'go [JOB ...] [MAIN]',
         'Run each (or every) JOB for MAIN (or inferred) document'
    def go(*args)
      jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      flags = ['-pdf', '-interaction=nonstopmode']
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end

    desc 'exec [JOB ...] [LATEXMK_OPTION ...] [MAIN]',
         'Run each (or every) JOB for MAIN (or inferred) document'
    def exec(*args)
      jobs, flags, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end

    desc 'dir [JOB] [MAIN]',
         'Print dir of JOB (or source) for MAIN (or inferred) document'
    def dir(*args)
      jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)

      if jobs.empty?
        puts main.dirname
      else
        jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main, work_path: cfg['work_path'] }
        jobs.map!(&:target_dir)
        puts jobs
      end
    end

    desc 'pdf [JOB ...] [MAIN]',
         'Print PDF path of each (or every) JOB for MAIN (or inferred) document'
    def pdf(*args)
      jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)

      jobs = cfg['jobs'] if jobs.empty?
      jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main, work_path: cfg['work_path'] }
      jobs.map! { |porter| porter.target_path.sub_ext('.pdf') }
      puts jobs
    end
  end
end
