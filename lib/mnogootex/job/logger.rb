# frozen_string_literal: true

require 'colorize'

module Mnogootex
  module Job
    class Logger < Thread
      def initialize(spinner:, processor:, runners:, porters:)
        super do
          while runners.any?(&:alive?)
            self.class.print_status(runners: runners, spinner: spinner)
            sleep 0.02 # 50 fps
          end
          self.class.print_status(runners: runners, spinner: spinner)
          puts
          self.class.print_outcome(runners: runners, porters: porters, processor: processor)
        end
      end

      class << self
        def print_status(runners:, spinner:)
          spinners_frames = []
          runners.each do |runner|
            spinner_frame = spinner[runner.count_lines % spinner.size]
            spinners_frames << colour_by_state(spinner_frame, runner)
          end
          print "Runners: #{spinners_frames.join}\r"
        end

        def print_outcome(runners:, porters:, processor:)
          puts 'Outcome:'
          porters.zip(runners).each do |porter, runner|
            outcome_icon = runner.successful? ? '✔'.green : '✘'.red
            puts "  #{outcome_icon} #{porter.hid}"
            puts processor.call(runner.log_lines) unless runner.successful?
          end
        end

        private

        def colour_by_state(string, runner)
          if runner.alive?
            string.yellow
          elsif runner.successful?
            string.green
          else
            string.red
          end
        end
      end
    end
  end
end
