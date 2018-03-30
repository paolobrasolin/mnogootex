# frozen_string_literal: true

require 'byebug'

module Mnogootex
  module Job
    class Poller < Thread
      def initialize(ticker:, throttler:, input:, output:, delay:)
        super do
          loop do
            if throttler.call
              line = input.gets
              break if line.nil?
              output.push(line)
              ticker.call(1)
              sleep delay
            else
              lines = input.read.lines
              break if lines.empty?
              output.concat(lines)
              ticker.call(lines.size)
              # break
            end
          end
        end
      end
    end
  end
end
