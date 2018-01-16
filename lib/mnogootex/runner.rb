# coding: utf-8
module Mnogootex
  class Runner
    attr_reader :source, :configuration

    def initialize(source:, configuration:)
      @mutex = Mutex.new
      @source = source
      @configuration = configuration

      @anim = configuration['animation'].freeze

      @jobs = []
      @threads = []
      @draw_threads = []

      @threads = []

      STDOUT.sync = true
    end

    def start
      puts "Mnogootex v#{Mnogootex::VERSION}"

      draw_status

      configuration['jobs'].each do |cls|
        @jobs << Mnogootex::Job.new(cls: cls, target: source, runner: self)
      end

      @jobs.map(&:setup)
      @jobs.map(&:run)
      @draw_threads = @jobs.map(&:tick_thread)
      @threads = @jobs.map(&:thread)

      @threads.map(&:join)
      @draw_threads.map(&:join)

      # Wait for completion

      puts
      puts '  Details:'
      @jobs.each do |job|
        if job.success?
          puts '    ' + "✔".green + ' ' + File.basename(job.cls)
        else
          puts '    ' + "✘".red + ' ' + File.basename(job.cls)
          puts job.log[2..-2].join.gsub(/^/,' '*6).chomp.red
        end
      end
    end

    def draw_status
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
  end
end
