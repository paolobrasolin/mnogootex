# frozen_string_literal: true

require 'open3'

module Mnogootex
  module Job
    class Runner
      attr_reader :hid, :log_lines

      def initialize(cl:, chdir:)
        @log_lines = []
        _, @stream, @thread = Open3.popen2e(*cl, chdir: chdir)
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
          until (line = @stream.gets).nil?
            log_lines << line
          end
          # NOTE: waits on @thread and returns its value
          @thread.value
        end
      end
    end
  end
end
