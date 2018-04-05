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
        @thread.alive? || @poller.alive?
      end

      def successful?
        @poller.value
        @thread.value.exitstatus.zero?
      end

      def count_lines
        @ticks = [@ticks || -1, @log_lines.size - 1].min + 1
      end

      private

      def start_poller
        Thread.new do
          until (line = @stream.gets).nil?
            @log_lines << line
          end
        end
      end
    end
  end
end
