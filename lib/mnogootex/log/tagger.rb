# frozen_string_literal: true

require 'mnogootex/log/line'
require 'mnogootex/log/matcher'

module Mnogootex
  module Log
    class Tagger
      attr_reader :matchers

      def initialize(matchers)
        @matchers = matchers
        prepare_matchers
      end

      def parse(lines)
        @lines = lines.dup
        prepare_lines!
        apply_matchers!
        @lines
      end

      private

      def prepare_matchers
        @matchers.map! do |matcher|
          Matcher.new matcher.fetch('regexp'),
                      matcher.fetch('loglvl', 'trace'),
                      matcher.fetch('length', 1)
        end
      end

      def prepare_lines!
        @lines.map! do |line|
          Line.new nil, line.chomp
        end
      end

      def apply_matchers!
        tail_length = 0
        matcher = nil
        @lines.each do |line|
          if tail_length.zero?
            matcher = @matchers.detect { |m| line.text =~ m.regexp }
            tail_length = matcher&.length&.-(1) || 0
          else # still on the tail of the previous match
            tail_length -= 1
          end
          line.loglvl = matcher&.loglvl
        end
      end
    end
  end
end
