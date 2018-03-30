# frozen_string_literal: true

require 'colorize'

module Mnogootex
  module Job
    class Logger
      def initialize(animation:, processor:, workers:)
        @animation_frames = animation
        @animation_length = animation.length
        @processor = processor
        @workers = workers
      end

      def print_status
        icons = @workers.map do |job|
          icon = @animation_frames[job.log.length % @animation_length]
          if job.running?
            icon.yellow
          else
            job.success? ? icon.green : icon.red
          end
        end
        print 'Workers: ' + icons.join + "\r"
      end

      def print_outcome
        puts 'Outcome:'
        @workers.each do |job|
          if job.success?
            puts '  ' + '✔'.green + ' ' + File.basename(job.id)
          else
            puts '  ' + '✘'.red + ' ' + File.basename(job.id)
            puts @processor.call(job.log)
          end
        end
      end
    end
  end
end
