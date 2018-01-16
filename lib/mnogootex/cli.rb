require 'pathname'

module Mnogootex
  module CLI
    def self.recombobulate
      symlinked_main = Pathname.new('.mnogootex.main')
      explicit_main = Pathname.new(ARGV.last)
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

    def self.clobber
      dirmask = Pathname.new(Dir.tmpdir).join('mnogootex-*')
      dirlist = Dir.glob(dirmask)
      total_bytes = files_size(dirmask.join('**', '*'))
      print "Deleting #{dirlist.length} folders to free #{human_bytes total_bytes}... "
      FileUtils.rm_r dirlist, secure: true
      puts 'Done.'
    end

    def self.files_size(mask)
      Dir.glob(mask).map! { |f| Pathname.new(f).size }.inject(:+) || 0
    end

    def self.human_bytes(size)
      return "#{size}b"  if  size          < 1024
      return "#{size}Kb" if (size /= 1024) < 1024
      return "#{size}Mb" if (size /= 1024) < 1024
      return "#{size}Gb" if (size /= 1024) < 1024
      return "#{size}Tb" if  size /= 1024
    end
  end
end
