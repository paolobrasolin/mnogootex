require 'digest'
require 'tmpdir'
require 'pathname'
require 'base64'

module Mnogootex
  class Job
    attr_reader :thread, :stdout_stderr, :log, :ticks, :cls, :streaming

    def initialize(cls:, target:)
      @main_path = File.expand_path target
      @main_basename = File.basename @main_path
      @main_dirname = File.dirname @main_path
      raise "File non esiste." unless File.exist? @main_path

      @cls = cls
      @log = []
      @ticks = 0
      @streaming = true

      @source_id = Base64.urlsafe_encode64 Digest::MD5.digest(@main_path)
    end

    def success?
      @thread.value.exitstatus == 0
    end

    def tmp_dirname
      @tmp_dirname ||= Pathname.new(Dir.tmpdir).join('mnogootex', @source_id, @cls)
    end

    def setup
      FileUtils.rm_r tmp_dirname, secure: true if tmp_dirname.directory?
      FileUtils.mkdir_p tmp_dirname

      # TODO: cleanup target folder
      FileUtils.cp_r File.join(@main_dirname, '.'), tmp_dirname

      @path = File.join tmp_dirname, @main_basename

      code = File.read @path
      replace = code.sub /\\documentclass(\[.*?\])?{.*?}/,
                         "\\documentclass{#{@cls}}"

      File.open @path, "w" do |file|
        file.puts replace
      end

      FileUtils.rm tmp_dirname.join('.mnogootex.yml')
      tmp_dirname.join('.mnogootex.main').make_symlink(@main_path)
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

    def stream_poller(synced_signaler, delay: 0.05)
      @stream_poller ||=
        Thread.new do
          loop do
            line = @stdout_stderr.gets
            break unless !line.nil? || @thread.alive?
            synced_signaler.call { @ticks += 1 }
            @log << line
            sleep delay if @thread.alive?
          end
          synced_signaler.call { @streaming = false }
        end
    end
  end
end
