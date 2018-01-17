# coding: utf-8

module Mnogootex
  class Runner
    attr_reader :source, :configuration

    def initialize(source:, configuration:)
      @mutex = Mutex.new
      @covar = ConditionVariable.new

      @source = source
      @configuration = configuration

      @anim = configuration['animation'].freeze

      @jobs = []
      @threads = []

      # STDOUT.sync = true
    end

    def start
      configuration['jobs'].each do |cls|
        @jobs << Mnogootex::Job.new(cls: cls, target: source)
      end

      @jobs.map(&:setup)

      @threads << stata_drawer

      @jobs.each do |job|
        job.run(configuration['commandline'])
        @threads << job.thread
        @threads << job.stream_poller(method(:synced_signaler))
      end

      @threads.map(&:join)

      puts # terminate last line redraw by stata_drawer
      print_details
    end

    def print_details
      puts '  Details:'
      @jobs.each do |job|
        if job.success?
          puts '    ' + "✔".green + ' ' + File.basename(job.cls)
        else
          puts '    ' + "✘".red + ' ' + File.basename(job.cls)
          # puts job.log[2..-2].join.gsub(/^/,' '*6).chomp.red
          puts job.log.join.gsub(/^/,' '*6).chomp.red
        end
      end
    end

    def redraw_status
      icons = @jobs.map do |j|
        icon = @anim[j.ticks % @anim.length]
        case j.thread.status
        when 'sleep', 'run', 'aborting'
          icon.yellow
        when false, nil # exited (normally or w/ error)
          j.success? ? icon.green : icon.red
        end
      end
      print '  Jobs: ' + icons.join + "\r"
    end

  private

    def stata_drawer
      @state_logger ||= Thread.new do
        synced_while ->() { @jobs.map(&:streaming).any? } do
          redraw_status
        end
      end
    end

    def synced_signaler
      @mutex.synchronize do
        yield if block_given?
        @covar.signal
      end
    end

    def synced_while(condition)
      @mutex.synchronize do
        while condition.call
          @covar.wait(@mutex)
          yield
        end
      end
    end
  end
end
