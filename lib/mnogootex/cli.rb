# frozen_string_literal: true

require 'thor'
require 'pathname'

require 'mnogootex/utils'
require 'mnogootex/job/warden'
require 'mnogootex/job/porter'
require 'mnogootex/cfg'

module Mnogootex
  class CLI < Thor
    desc 'exec [JOB ...] [FLAG ...] ROOT',
         'Execute latexmk with FLAGs on each JOB for ROOT document'
    def exec(*args)
      execute_latexmk(*args, default_flags: [])
    end

    desc 'build [JOB ...] [FLAG ...] ROOT',
         'Build each JOB for ROOT document'
    def build(*args)
      execute_latexmk(*args, default_flags: ['-interaction=nonstopmode'])
    end

    desc 'open [JOB ...] [FLAG ...] ROOT',
         '(Build and) open the artifact of each JOB for ROOT document'
    def open(*args)
      execute_latexmk(*args, default_flags: ['-interaction=nonstopmode', '-pv'])
    end

    desc 'clean [JOB ...] [FLAG ...] ROOT',
         'Delete nonessential files of each JOB for ROOT document'
    def clean(*args)
      execute_latexmk(*args, default_flags: ['-c'])
    end

    desc 'clobber [JOB ...] [FLAG ...] ROOT',
         'Delete nonessential files and artifacts of each JOB for ROOT document'
    def clobber(*args)
      execute_latexmk(*args, default_flags: ['-C'])
    end
    
    desc 'help [COMMAND]',
         'Describe available commands or one specific COMMAND'
    def help(*args)
      super

      puts <<~EXTRA_HELP
        JOBs are document class names. The default is the whole list in your configuration file.
        FLAGs are options passed to latexmk. Please refer to `latexmk -help` for details.
      EXTRA_HELP
    end

    # desc 'purge',
    #      'Clean up all work files'
    # def purge
    #   _, _, _, cfg = Mnogootex::Cfg.recombobulate(*args)

    #   tmp_dir = if (path = cfg['work_path']).nil?
    #     Pathname.new(Dir.tmpdir).join('mnogootex')
    #   else
    #     Pathname.new(path)
    #   end

    #   tmp_dir_size = Mnogootex::Utils.humanize_bytes Mnogootex::Utils.dir_size(tmp_dir)
    #   print "Freeing up #{tmp_dir_size} in #{tmp_dir}... "
    #   FileUtils.rm_r tmp_dir, secure: true if tmp_dir.directory?
    #   puts 'Done.'
    # end

    # desc 'dir [JOB] [MAIN]',
    #      'Print dir of JOB (or source) for MAIN (or inferred) document'
    # def dir(*args)
    #   jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)

    #   if jobs.empty?
    #     puts main.dirname
    #   else
    #     jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main, work_path: cfg['work_path'] }
    #     jobs.map!(&:target_dir)
    #     puts jobs
    #   end
    # end

    # desc 'pdf [JOB ...] [MAIN]',
    #      'Print PDF path of each (or every) JOB for MAIN (or inferred) document'
    # def pdf(*args)
    #   jobs, _, main, cfg = Mnogootex::Cfg.recombobulate(*args)

    #   jobs = cfg['jobs'] if jobs.empty?
    #   jobs.map! { |hid| Mnogootex::Job::Porter.new hid: hid, source_path: main, work_path: cfg['work_path'] }
    #   jobs.map! { |porter| porter.target_path.sub_ext('.pdf') }
    #   puts jobs
    # end

  private

    def execute_latexmk(*args, default_flags: [])
      jobs, flags, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      flags = [*default_flags, *flags]
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end
  end
end
