# frozen_string_literal: true

require 'pathname'
require 'digest'
require 'base64'
require 'tmpdir'
require 'open3'

module Mnogootex
  module Job
    class Worker
      attr_reader :log, :id

      def initialize(id:, source:)
        @source_path = Pathname.new(source) # .realpath

        @id = id
        @log = []
      end

      def target_dir
        @target_dir ||= Pathname.new(Dir.tmpdir).join('mnogootex', source_id, id)
      end

      def setup(target_files_transformer = nil)
        setup_target_files
        target_files_transformer&.call(target_path)
      end

      attr_reader :runner

      def start_runner(commandline)
        # NOTE: while we ought to be distinguishing out and err, the engines
        #   uses them pretty inconsistently so it's not worth the effort atm.
        _, @stdout_stderr, @runner = Open3.popen2e(
          *commandline.call(target_path),
          chdir: target_dir
        )
      end

      def running?
        # NOTE: status of a terminated thread is either false/nil (normal/exception)
        runner&.status&.!&.!
      end

      def success?
        runner&.value&.exitstatus&.zero?
      end

      attr_reader :poller

      def start_poller(ticker, delay:)
        # NOTE: gets and read wait for a line, so nil and [] mean the stream closed
        @poller =
          Thread.new do
            loop do
              if running?
                line = @stdout_stderr.gets
                break if line.nil?
                log << line
                ticker.call(1)
                sleep delay
              else
                lines = @stdout_stderr.read.lines
                break if lines.empty?
                @log += lines
                ticker.call(lines.size)
              end
            end
          end
      end

      def polling?
        # NOTE: status of a terminated thread is either false/nil (normal/exception)
        poller&.status&.!&.!
      end

      private

      def source_id
        @source_id ||= Base64.urlsafe_encode64 Digest::MD5.digest(@source_path.to_s)
      end

      def target_path
        @target_path ||= target_dir.join(@source_path.basename)
      end

      def setup_target_files
        target_dir.rmtree if target_dir.directory?
        target_dir.mkpath
        # NOTE: can't use Pathname.join here since it elides the dot:
        FileUtils.cp_r File.join(@source_path.dirname, '.'), target_dir
        target_dir.join('.mnogootex.yml').tap { |p| p.delete if p.file? }
        target_dir.join('.mnogootex.src').make_symlink(@source_path)
      end
    end
  end
end
