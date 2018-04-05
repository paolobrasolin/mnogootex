# frozen_string_literal: true

require 'colorize'

module Mnogootex
  module Job
    class Logger < Thread
      def initialize(animation:, processor:, runners:, porters:)
        @animation_frames = animation
        @animation_length = animation.length
        @processor = processor
        @runners = runners
        @porters = porters
        super do
          while @runners.any?(&:alive?)
            print_status
            sleep 0.02 # 50 fps
          end
          print_status
          puts
          print_outcomes
        end
      end

      def print_status
        icons = []
        @runners.each do |runner|
          icon = @animation_frames[runner.count_lines % @animation_length]
          icons << if runner.alive?
                     icon.yellow
                   elsif runner.successful?
                     icon.green
                   else
                     icon.red
                   end
        end
        print 'Runners: ' + icons.join + "\r"
      end

      def print_outcomes
        puts 'Outcome:'
        @porters.zip(@runners).each do |porter, runner|
          if runner.successful?
            puts '  ' + '✔'.green + ' ' + porter.hid
          else
            puts '  ' + '✘'.red + ' ' + porter.hid
            puts @processor.call(runner.stream_lines)
          end
        end
      end
    end
  end
end
