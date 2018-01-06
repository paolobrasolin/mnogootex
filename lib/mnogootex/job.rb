require 'digest'
require 'tmpdir'
require 'pathname'

module Mnogootex
  class Job
    attr_reader :thread, :stdout_stderr, :log, :ticks, :cls

    def initialize(cls:, target:)
      @main_path = File.expand_path target
      @main_basename = File.basename @main_path
      @main_dirname = File.dirname @main_path
      raise "File non esiste." unless File.exist? @main_path

      @cls = cls
      @log = []
      @ticks = 0

      @id = Digest::MD5.hexdigest(@cls + @main_path)
    end

    def success?
      @thread.value.exitstatus == 0
    end

    def tmp_dirname
      @tmp_dirname ||= Pathname(Dir.tmpdir).join("mnogootex-#{@id}")
    end

    def setup
      FileUtils.cp_r File.join(@main_dirname, '.'), tmp_dirname

      @path = File.join tmp_dirname, @main_basename

      code = File.read @path
      replace = code.sub /\\documentclass(\[.*?\])?{.*?}/,
                        "\\documentclass{#{@cls}}"

      File.open @path, "w" do |file|
        file.puts replace
      end
    end

    def run
      _, @stdout_stderr, @thread = Open3.popen2e(
        "texfot",
        "pdflatex",
        # "latexmk",
        # "-pdf",
        "--shell-escape", # TODO: remove me!
        "--interaction=nonstopmode",
        @main_basename,
        chdir: tmp_dirname
      )
    end

    def tick_thread
      Thread.new do
        # 50ms polling cycle
        until (line = @stdout_stderr.gets).nil? do
          sleep 0.05
          @log << line
          @ticks += 1
          draw_status
          break unless @thread.alive?
        end
        # end of life treatment
        lines = @stdout_stderr.read.lines
        @log.concat lines
        @ticks += lines.length
        draw_status
      end
    end
  end
end
