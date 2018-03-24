# frozen_string_literal: true

require 'pathname'
require 'digest'
require 'base64'
require 'tmpdir'
require 'open3'

module Mnogootex
  module Job
    class Worker
      attr_reader :thread, :log, :ticks, :streaming, :cls

      def initialize(cls:, source:)
        @source_path = Pathname.new(source).realpath

        @cls = cls
        @log = []
        @ticks = 0
        @streaming = true
      end

      def success?
        @thread.value.exitstatus.zero?
      end

      def target_dir
        @target_dir ||= Pathname.new(Dir.tmpdir).join('mnogootex', source_id, @cls)
      end

      def output_path
        @output_path ||= target_dir.join(@source_path.basename.sub_ext('.pdf'))
      end

      def setup
        setup_target_files
        setup_target_code
      end

      def start(commandline)
        # NOTE: while we ought to be distinguishing out and err, the engines
        #   uses them pretty inconsistently so it's not worth the effort atm.
        _, @stdout_stderr, @thread = Open3.popen2e(
          *commandline,
          @source_path.basename.to_s,
          chdir: target_dir
        )
      end

      def stream_poller(state_change_signaler, delay: 0.04)
        @stream_poller ||=
          Thread.new do
            loop do
              line = @stdout_stderr.gets
              break unless !line.nil? || @thread.alive?
              @ticks += 1
              state_change_signaler.call
              @log << line
              sleep delay if @thread.alive?
            end
            state_change_signaler.call { @streaming = false }
          end
      end

      private

      def source_id
        @source_id ||= Base64.urlsafe_encode64 Digest::MD5.digest(@source_path.to_s)
      end

      def setup_target_files
        target_dir.rmtree if target_dir.directory?
        target_dir.mkpath
        # NOTE: can't use Pathname.join here since it elides the dot:
        FileUtils.cp_r File.join(@source_path.dirname, '.'), target_dir
        target_dir.join('.mnogootex.yml').tap { |p| p.delete if p.file? }
        target_dir.join('.mnogootex.src').make_symlink(@source_path)
      end

      # TODO: abstract away
      def setup_target_code
        target_path = target_dir.join(@source_path.basename)
        code = target_path.read
        replace = code.sub(
          /\\documentclass(\[.*?\])?{.*?}/,
          "\\documentclass{#{@cls}}"
        )
        target_path.write(replace)
      end
    end
  end
end
