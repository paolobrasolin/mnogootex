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

  private

    def execute_latexmk(*args, default_flags: [])
      jobs, flags, main, cfg = Mnogootex::Cfg.recombobulate(*args)
      cfg = Mnogootex::Cfg::DEFAULTS.merge(cfg).merge({ 'jobs' => jobs }.compact)
      flags = [*default_flags, *flags]
      Mnogootex::Job::Warden.new(source: main, configuration: cfg, flags: flags).start
    end
  end
end
