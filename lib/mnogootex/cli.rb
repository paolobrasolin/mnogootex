# frozen_string_literal: true

require 'thor'
require 'pathname'

require 'mnogootex/utils'
require 'mnogootex/job/warden'
require 'mnogootex/job/porter'
require 'mnogootex/cfg'

module Mnogootex
  class CLI < Thor
    desc 'exec [JOB ...] [LATEXMK_OPTION ...] MAIN',
         'Execute latexmk on each (or every) JOB with the given LATEXMK_OPTION for MAIN document'
    def exec(*args)
      jobs, flags, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      # flags are read from the commandline given by the user
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end

    desc 'go [JOB ...] MAIN',
         'Run each (or every) JOB for MAIN document'
    def go(*args)
      jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      flags = ['-pdf', '-interaction=nonstopmode']
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end

    desc 'open [JOB ...] MAIN',
         'Open PDF of each (or every) JOB for MAIN document'
    def open(*args);
      jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      flags = ['-pv', '-interaction=nonstopmode']
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end

    desc 'clean [JOB ...] MAIN',
         'Delete temporary files on each (or every) JOB for MAIN document'
    def clean(*args)
      jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      flags = ['-c', '-interaction=nonstopmode']
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end

    desc 'clobber [JOB ...] MAIN',
         'Delete temporary files and artifacts on each (or every) JOB for MAIN document'
    def clobber(*args)
      jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      flags = ['-C', '-interaction=nonstopmode']
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end

  #   desc 'purge',
  #        'Clean up all work files'
  #   def purge 
  #     _, _, _, cfg = Mnogootex::Cfg.recombobulate(*args)
      
  #     tmp_dir = if (path = cfg['work_path']).nil?
  #       Pathname.new(Dir.tmpdir).join('mnogootex')
  #     else
  #       Pathname.new(path)
  #     end

  #     tmp_dir_size = Mnogootex::Utils.humanize_bytes Mnogootex::Utils.dir_size(tmp_dir)
  #     print "Freeing up #{tmp_dir_size} in #{tmp_dir}... "
  #     FileUtils.rm_r tmp_dir, secure: true if tmp_dir.directory?
  #     puts 'Done.'
  #   end


  #   desc 'dir [JOB] [MAIN]',
  #        'Print dir of JOB (or source) for MAIN (or inferred) document'
  #   def dir(*args)
  #     jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)

  #     if jobs.empty?
  #       puts main.dirname
  #     else
  #       jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main, work_path: cfg['work_path'] }
  #       jobs.map!(&:target_dir)
  #       puts jobs
  #     end
  #   end

  #   desc 'pdf [JOB ...] [MAIN]',
  #        'Print PDF path of each (or every) JOB for MAIN (or inferred) document'
  #   def pdf(*args)
  #     jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)

  #     jobs = cfg['jobs'] if jobs.empty?
  #     jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main, work_path: cfg['work_path'] }
  #     jobs.map! { |porter| porter.target_path.sub_ext('.pdf') }
  #     puts jobs
  #   end
  # end
end
