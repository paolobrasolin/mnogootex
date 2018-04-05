# frozen_string_literal: true

require 'open3'

module Mnogootex
  module Job
    class Runner
      attr_reader :hid

      def initialize(cl:, chdir:)
        _, @stream, @thread = Open3.popen2e(*cl, chdir: chdir)
      end

      def alive?
        @thread.alive?
      end

      def successful?
        @thread.value.exitstatus.zero?
      end

      def count_lines
        @ticks = [@ticks || -1, approx_stream_lines_count - 1].min + 1
      end

      def stream_lines
        @stream_lines ||= @stream.read.lines
      end

      private

      def approx_stream_lines_count
        @stream.stat.size.fdiv(80).ceil
      end
    end
  end
end
