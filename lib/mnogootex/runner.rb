# frozen_string_literal: true

require 'colorize'

require 'mnogootex/log/tagger'

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
      tagger = Log::Tagger.new configuration['matchers']
      puts 'Details:'
      @jobs.each do |job|
        if job.success?
          puts '  ' + '✔'.green + ' ' + File.basename(job.cls)
        else
          puts '  ' + '✘'.red + ' ' + File.basename(job.cls)
          puts render_tagged_log tagger.parse(job.log)
        end
      end
    end

    COLOURS = {
      trace: :white,
      info: :light_white,
      warning: :light_yellow,
      error: :light_red
    }.freeze

    LEVELS = {
      trace: 0,
      info: 1,
      warning: 2,
      error: 3
    }.freeze

    def render_tagged_log(tagged_log)
      tagged_log.
        select { |line| LEVELS[line.tag] >= LEVELS[:info] }.
        each { |line| line.text = line.text.send(COLOURS[line.tag]) }.
        map(&:text).join("\n").gsub(/^/, ' ' * 4).chomp
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
