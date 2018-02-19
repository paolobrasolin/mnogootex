# frozen_string_literal: true

require 'mnogootex/log'
require 'mnogootex/log/line'

module Mnogootex
  module Log
    # This class exposes methods to
    # {Processor.strings_to_lines! convert} strings into {Line}s that can be
    # {Processor.tag_lines! tagged},
    # {Processor.filter_lines! filtered},
    # {Processor.colorize_lines! colored} (using {Level}s and {Matcher}s to define how)
    # and finally
    # {Processor.render_lines! rendered} into printable content.
    #
    # It can also be {Processor.initialize instantiated} with a specific configuration
    # to {#run} the whole process repeatably on multiple inputs.
    class Processor
      # Converts strings into {Line}s.
      #
      # @param strings [Array<String>]
      # @return [Array<Line>]
      def self.strings_to_lines!(strings)
        strings.map! do |line|
          Line.new line.chomp, nil
        end
      end

      # Updates {Line#level}s of the given {Line}s using the {Matcher}s.
      #
      # @param lines [Array<Line>]
      # @param matchers [Array<Matcher>]
      # @return [Array<Line>]
      def self.tag_lines!(lines, matchers:)
        tail_length, matcher = 0 # , nil
        lines.each do |line|
          if tail_length.zero?
            matcher = matchers.detect { |m| line.text =~ m.regexp }
            tail_length = matcher&.length&.-(1) || 0
          else # still on the tail of the previous match
            tail_length -= 1
          end
          line.level = matcher&.level
        end
      end

      # Discards {Line}s having {Line.level}s with {Level#priority}
      # lower than the minimum, according the {Level}s hash.
      #
      # @param lines [Array<Line>]
      # @param levels [Hash<Symbol, Level>]
      # @param min_level [Symbol]
      # @return [Array<Line>]
      def self.filter_lines!(lines, levels:, min_level:)
        lines.select! do |line|
          levels[line.level].priority >= levels[min_level].priority
        end
      end

      # Applies {Level#color}s to the {Line}s, according the {Level}s hash.
      #
      # @param lines [Array<Line>]
      # @param levels [Array<Level>]
      # @return [Array<Line>]
      def self.colorize_lines!(lines, levels:)
        lines.each do |line|
          line.text = line.text.colorize(levels[line.level].color)
        end
      end

      # Renders {Line}s to space-indented strings terminated by a newline.
      #
      # @param lines [Array<Line>]
      # @param indent_width [Fixnum]
      # @return [Array<String>]
      def self.render_lines!(lines, indent_width:)
        lines.map! { |line| "#{' ' * indent_width}#{line.text}\n" }
      end

      # @param matchers [Array<Matcher>]
      # @param levels [Array<Level>]
      # @param indent_width [Fixnum]
      # @param min_level [Symbol]
      def initialize(matchers:, levels:, min_level:, colorize:, indent_width:)
        @matchers = matchers
        @levels = levels
        @min_level = min_level
        @colorize = colorize
        @indent_width = indent_width
      end

      # Runs the {Processor Processor} on the given strings to
      # {Processor.strings_to_lines! convert},
      # {Processor.tag_lines! tag},
      # {Processor.filter_lines! filter},
      # {Processor.colorize_lines! color} and
      # {Processor.render_lines! render} them
      # using its {Processor.initialize initialization} parameters.
      #
      # @param lines [Array<String>]
      # @return [Array<String>]
      def run(lines)
        @lines = lines.dup
        Processor.strings_to_lines! @lines
        Processor.tag_lines! @lines, matchers: @matchers
        Processor.filter_lines! @lines, levels: @levels, min_level: @min_level
        Processor.colorize_lines! @lines, levels: @levels if @colorize
        Processor.render_lines! @lines, indent_width: @indent_width
        @lines
      end
    end
  end
end
