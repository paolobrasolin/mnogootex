# frozen_string_literal: true

require 'thor'
require 'pathname'

require 'mnogootex/constants'

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
      _, main, opts = recombobulate(*args)
      Mnogootex::Runner.new(source: main, configuration: opts).start
    end

    desc 'dir [JOBS ...] [MAIN]',
         'Print target dirs relative to JOBS for MAIN document'
    def dir(*args)
      jobs, main, = recombobulate(*args)

      if jobs.empty?
        puts main.dirname
      else
        jobs.map! { |job| Mnogootex::Job.new cls: job, target: main }
        jobs.map!(&:tmp_dir)
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
        jobs.map! { |job| Mnogootex::Job.new cls: job, target: main }
        jobs.map!(&:pdf_path)
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

    def dir_size(mask)
      Dir.glob(Pathname.new(mask).join('**', '*')).
        map! { |f| Pathname.new(f).size }.inject(:+) || 0
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
