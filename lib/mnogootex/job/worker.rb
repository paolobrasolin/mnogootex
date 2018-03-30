# frozen_string_literal: true

require 'open3'

require 'mnogootex/job/poller'
require 'mnogootex/job/sitter'

module Mnogootex
  module Job
    class Worker
      attr_reader :log, :stdout_stderr

      def initialize(id:, source:)
        @sitter = Mnogootex::Job::Sitter.new(id: id, source: source)

        @log = []
      end

      def id
        @sitter.id
      end

      def target_dir
        @sitter.target_dir
      end

      def setup(target_files_transformer = nil)
        @sitter.setup(target_files_transformer)
      end

      attr_reader :runner

      def start_runner(commandline)
        # NOTE: while we ought to be distinguishing out and err, the engines
        #   uses them pretty inconsistently so it's not worth the effort atm.
        _stdin, @stdout_stderr, @runner = Open3.popen2e(
          *commandline.call(@sitter.target_path),
          chdir: @sitter.target_dir
        )
      end

      def running?
        runner&.alive?
      end

      def success?
        runner&.value&.exitstatus&.zero?
      end

      attr_reader :poller

      def start_poller(ticker, delay:)
        @poller = Mnogootex::Job::Poller.new(
          ticker: ticker,
          throttler: method(:running?),
          input: @stdout_stderr,
          output: @log,
          delay: delay
        )
      end

      def polling?
        poller&.alive?
      end
    end
  end
end
