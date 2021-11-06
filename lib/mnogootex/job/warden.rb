# frozen_string_literal: true

require 'colorize'

require 'mnogootex/log'
require 'mnogootex/log/processor'
require 'mnogootex/job/porter'
require 'mnogootex/job/runner'
require 'mnogootex/job/logger'

module Mnogootex
  module Job
    class Warden
      def initialize(source:, configuration:)
        @source = source
        @configuration = configuration

        @processor = nil
        @porters = []
        @runners = []
        @logger = nil
      end

      def start
        init_processor
        init_porters
        exec_porters
        init_and_exec_runners
        init_and_exec_logger
        @logger.join
      end

      private

      def init_porters
        @configuration['jobs'].each do |cls|
          @porters << Mnogootex::Job::Porter.new(
            hid: cls,
            source_path: @source,
            work_path: @configuration['work_path'],
          )
        end
      end

      def exec_porters
        @porters.each do |porter|
          porter.clobber
          porter.provide
          transformer(porter.hid, porter.target_path)
        end
      end

      def init_and_exec_runners
        @runners = @porters.map do |porter|
          Mnogootex::Job::Runner.new(
            cmd: commandline(porter.target_path),
            chdir: porter.target_dir
          )
        end
      end

      def init_processor
        @processor = Log::Processor.new(
          matchers: Mnogootex::Log::DEFAULT_MATCHERS,
          levels: Mnogootex::Log::DEFAULT_LEVELS,
          min_level: :info,
          colorize: true,
          indent_width: 4
        )
      end

      def init_and_exec_logger
        @logger = Mnogootex::Job::Logger.new(
          spinner: @configuration['spinner'],
          processor: @processor.method(:run),
          runners: @runners,
          porters: @porters
        )
      end

      # TODO: generalize, integrate with Runner
      def commandline(target_pathname)
        [
          *@configuration['commandline'],
          target_pathname.basename.to_s
        ]
      end

      # TODO: generalize, integrate with Porter
      def transformer(new_class_name, target_pathname)
        old_code = target_pathname.read
        new_code = old_code.sub(
          /\\documentclass(\[.*?\])?{.*?}/,
          "\\documentclass{#{new_class_name}}"
        )
        target_pathname.write(new_code)
      end
    end
  end
end
