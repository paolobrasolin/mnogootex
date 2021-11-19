# frozen_string_literal: true

require 'open3'
require 'io/wait'

module Mnogootex
  module Job
    class Runner
      POLLING_TIMEOUT = 0.02

      attr_reader :hid, :log_lines

      def initialize(cmd:, chdir:)
        @log_lines = []
        _, @stream, @thread = Open3.popen2e(*cmd, chdir: chdir)
        @poller = start_poller
      end

      def alive?
        @poller.alive?
      end

      def successful?
        @poller.value.exitstatus.zero?
      end

      def count_lines
        return log_lines.size unless alive?

        @ticks = [@ticks || -1, log_lines.size - 1].min + 1
      end

      private

      def start_poller
        Thread.new do
          polling_loop

          # NOTE: waits on @thread and returns its value
          @thread.value
        end
      end

      def polling_loop
        loop do
          if @stream.wait_readable(POLLING_TIMEOUT).nil?
            # If the stream timeouts and the thread is dead we expect no nore data.
            # This happens on commands like `latexmk -pv` which fork other processes.
            break unless @thread.alive?
          else
            # If we reach EOF, we expect no more data.
            break if (line = @stream.gets).nil?

            log_lines << line
          end
        end
      end
    end
  end
end
