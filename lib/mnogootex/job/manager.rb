# frozen_string_literal: true

require 'colorize'

require 'mnogootex/log'
require 'mnogootex/log/processor'

module Mnogootex
  module Job
    class Manager
      attr_reader :source, :configuration

      def initialize(source:, configuration:)
        @source = source
        @configuration = configuration

        @anim_frames = configuration['animation']
        @anim_length = @anim_frames.length

        @jobs = []
        @threads = []
        @queue = Queue.new

        # STDOUT.sync = true
      end

      def start

        configuration['jobs'].each do |cls|
          @jobs << Mnogootex::Job::Worker.new(id: cls, source: source)
        end

        @jobs.zip(configuration['jobs']).each do |job, cls|
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

        @ticks = Array.new(@jobs.size, 0)

        @jobs.each_with_index do |job, i|
          job.start_runner(commandline)
          # @threads << job.runner
          ticker = ->(n) { n.times { @queue << i } }
          @threads << job.start_poller(ticker, delay: 0.02) # i.e. 50 fps
        end

        state_logger.join

        puts # to terminate last line redraw by state_logger

        print_details
      end

      private

      def redraw_status
        icons = @jobs.map do |j|
          icon = @anim_frames[j.log.length % @anim_length]
          if j.running?
            icon.yellow
          else
            j.success? ? icon.green : icon.red
          end
        end
        print 'Jobs: ' + icons.join + "\r"
      end

      def print_details
        processor = Log::Processor.new matchers: Mnogootex::Log::DEFAULT_MATCHERS,
                                       levels: Mnogootex::Log::DEFAULT_LEVELS,
                                       min_level: :info,
                                       colorize: true,
                                       indent_width: 4

        puts 'Details:'
        @jobs.each do |job|
          if job.success?
            puts '  ' + '✔'.green + ' ' + File.basename(job.id)
          else
            puts '  ' + '✘'.red + ' ' + File.basename(job.id)
            puts processor.run(job.log)
          end
        end
      end

      def state_logger
        @state_logger ||= Thread.new do
          while @jobs.any?(&:polling?)
            job_idx = @queue.pop
            @ticks[job_idx] += 1
            redraw_status
            sleep 0.02 # 50 fps
          end
          redraw_status
        end
      end
    end
  end
end
