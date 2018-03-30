# frozen_string_literal: true

require 'colorize'

require 'mnogootex/log'
require 'mnogootex/log/processor'
require 'mnogootex/job/logger'

module Mnogootex
  module Job
    class Manager
      attr_reader :source, :configuration

      def initialize(source:, configuration:)
        @source = source
        @configuration = configuration

        @workers = []
        @queue = Queue.new

        @processor = Log::Processor.new matchers: Mnogootex::Log::DEFAULT_MATCHERS,
                                        levels: Mnogootex::Log::DEFAULT_LEVELS,
                                        min_level: :info,
                                        colorize: true,
                                        indent_width: 4

        @logger = Mnogootex::Job::Logger.new animation: configuration['animation'],
                                             processor: @processor.method(:run),
                                             workers: @workers
      end

      def start
        configuration['jobs'].each do |cls|
          @workers << Mnogootex::Job::Worker.new(id: cls, source: source)
        end

        @workers.zip(configuration['jobs']).each do |job, cls|
          transformer = lambda do |target_path|
            code = target_path.read
            replace = code.sub(
              /\\documentclass(\[.*?\])?{.*?}/,
              "\\documentclass{#{cls}}"
            )
            target_path.write(replace)
          end
          job.setup(transformer)
        end


        commandline = lambda do |target_path|
          [*configuration['commandline'], target_path.basename.to_s]
        end

        @ticks = Array.new(@workers.size, 0)

        @workers.each_with_index do |job, i|
          job.start_runner(commandline)
          ticker = ->(n) { n.times { @queue << i } }
          job.start_poller(ticker, delay: 0.02) # i.e. 50 fps
        end

        state_logger.join

        puts # to terminate last line redraw by state_logger

        @logger.print_outcome
      end

      private

      def state_logger
        @state_logger ||= Thread.new do
          while @workers.any?(&:polling?)
            job_idx = @queue.pop
            @ticks[job_idx] += 1
            @logger.print_status
            sleep 0.02 # 50 fps
          end
          @logger.print_status
        end
      end
    end
  end
end
