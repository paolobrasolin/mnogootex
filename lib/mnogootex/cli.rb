# frozen_string_literal: true

require 'thor'
require 'pathname'

module Mnogootex
  class CLI < Thor
    # class_option :verbose, type: :boolean

    desc 'mnogoo',
         'Print path of the shell wrapper script mnogoo'
    def mnogoo
      puts Pathname.new(__dir__).join('cli', 'mnogoo.sh')
    end

    desc 'clobber',
         'Clean up all temporary files'
    def clobber
      tmp_dir = Pathname.new(Dir.tmpdir).join('mnogootex')
      tmp_dir_size = humanize_bytes dir_size(tmp_dir)
      print "Freeing up #{tmp_dir_size}... "
      FileUtils.rm_r tmp_dir, secure: true if tmp_dir.directory?
      puts 'Done.'
    end

    desc 'go [JOBS ...] [MAIN]',
         'Run compilation JOBS for MAIN document'
    def go(*args)
      _, main = parse_jobs_main(*args)
      main, opts = recombobulate(main)
      Mnogootex::Runner.new(source: main, configuration: opts).start
    end

    desc 'dir [JOBS ...] [MAIN]',
         'Print target dirs relative to JOBS for MAIN document'
    def dir(*args)
      jobs, main = parse_jobs_main(*args)
      main, = recombobulate(main)

      if jobs.empty?
        puts main.dirname
      else
        jobs.map! { |job| Mnogootex::Job.new cls: job, target: main }
        jobs.map!(&:tmp_dirname)
        puts jobs
      end
    end

    desc 'pdf [JOBS ...] [MAIN]',
         'Print pdf paths relative to JOBS for MAIN document'
    def pdf(*args)
      jobs, main = parse_jobs_main(*args)
      main, = recombobulate(main)

      if jobs.empty?
        puts Dir.glob(main.dirname.join('*.pdf')).first
      else
        jobs.map! { |job| Mnogootex::Job.new cls: job, target: main }
        jobs.map! { |job| Dir.glob(job.tmp_dirname.join('*.pdf')).first }
        puts jobs
      end
    end

    private

    def parse_jobs_main(*args)
      return [[], nil] if args.empty?
      return [args[0..-2], args.last] if Pathname.new(args.last).file?
      [args, nil]
    end

    def recombobulate(mainable)
      symlinked_main = Pathname.new('.mnogootex.main')
      explicit_main = Pathname.new(mainable.to_s)
      adjacent_cfg = Pathname.new('.mnogootex.yml')

      if symlinked_main.symlink? # then the pwd is the folder of a target
        main = symlinked_main.readlink.realpath
        cfg = Mnogootex::Configuration.new
        cfg.load main.dirname
      elsif explicit_main.file? # then the pwd is irrelevant
        main = explicit_main.realpath
        cfg = Mnogootex::Configuration.new
        cfg.load main.dirname
      elsif adjacent_cfg.file? # then the pwd is the folder of a source
        cfg = Mnogootex::Configuration.new
        cfg.load adjacent_cfg.realpath.dirname
        # and we expect the main to be configured and existing
        raise 'Configuration does not include main file.' if cfg['main'].nil?
        main = Pathname.new cfg['main']
        raise 'Configured main file does not exist.' unless main.file?
      end

      [main, cfg]
    end

    def dir_size(mask)
      Dir.glob(Pathname.new(mask).join('**', '*'))
         .map! { |f| Pathname.new(f).size }.inject(:+) || 0
    end

    def humanize_bytes(size)
      return "#{size}b"  if  size          < 1024
      return "#{size}Kb" if (size /= 1024) < 1024
      return "#{size}Mb" if (size /= 1024) < 1024
      return "#{size}Gb" if (size /= 1024) < 1024
      return "#{size}Tb" if  size /= 1024
    end
  end
end
