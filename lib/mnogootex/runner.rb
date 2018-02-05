# frozen_string_literal: true

require 'colorize'

require 'mnogootex/log'
require 'mnogootex/log/processor'

module Mnogootex
  class Runner
    attr_reader :source, :configuration

    def initialize(source:, configuration:)
      @state_mutex = Mutex.new
      @state_changed = ConditionVariable.new

      @source = source
      @configuration = configuration

      @anim_frames = configuration['animation']
      @anim_length = @anim_frames.length

      @jobs = []
      @threads = []

      # STDOUT.sync = true
    end

    def start
      configuration['jobs'].each do |cls|
        @jobs << Mnogootex::Job.new(cls: cls, target: source)
      end

      @jobs.map(&:setup)

      @threads << state_logger

      @jobs.each do |job|
        job.start(configuration['commandline'])
        @threads << job.thread
        @threads << job.stream_poller(method(:state_change_signaler))
      end

      @threads.map(&:join)

      puts # to terminate last line redraw by state_logger
      print_details
    end

    private

    def redraw_status
      icons = @jobs.map do |j|
        icon = @anim_frames[j.ticks % @anim_length]
        case j.thread.status
        when 'sleep', 'run', 'aborting'
          icon.yellow
        when false, nil # exited (normally or w/error resp.)
          j.success? ? icon.green : icon.red
        end
      end
      print 'Jobs: ' + icons.join + "\r"
    end

    def print_details
      processor = Log::Processor.new matchers: Mnogootex::Log::MATCHERS,
                                     levels: Mnogootex::Log::LEVELS,
                                     min_level: :info,
                                     colorize: true,
                                     indent_width: 4

      puts 'Details:'
      @jobs.each do |job|
        if job.success?
          puts '  ' + '✔'.green + ' ' + File.basename(job.cls)
        else
          puts '  ' + '✘'.red + ' ' + File.basename(job.cls)
          puts processor.run(job.log)
        end
      end
    end

    def state_logger
      @state_logger ||= Thread.new do
        @state_mutex.synchronize do
          while @jobs.map(&:streaming).any?
            @state_changed.wait @state_mutex
            redraw_status
          end
        end
      end
    end

    def state_change_signaler
      @state_mutex.synchronize do
        yield if block_given?
        @state_changed.signal
      end
    end
  end
end
