# frozen_string_literal: true

require_relative '../../test_helper.rb'
require_relative '../../../lib/mnogootex/log/processor'

module Mnogootex
  module Log
    class ProcessorTest < Minitest::Test
      def test_it_converts_strings_into_lines
        strings = "foo\nbar\n".lines

        Processor.strings_to_lines! strings

        assert_equal [
          Line.new('foo'),
          Line.new('bar')
        ], strings
      end

      def test_it_tags_using_short_matchers
        lines = [Line.new('foo')]

        matchers = [Matcher.new(/foo/, :foo)]

        Processor.tag_lines! lines, matchers: matchers

        assert_equal :foo, lines.first.level
      end

      def test_it_tags_using_long_matchers
        lines = [Line.new('foo'),
                 Line.new('bar'),
                 Line.new('baz')]

        matchers = [Matcher.new(/foo/, :foo, 3)]

        Processor.tag_lines! lines, matchers: matchers

        assert_equal %i[foo foo foo], lines.map(&:level)
      end

      def test_it_tags_abiding_to_matchers_order
        lines = [Line.new('foo')]

        matchers = [Matcher.new(/foo/, :winner, 1),
                    Matcher.new(/foo/, :loser, 1)]

        Processor.tag_lines! lines, matchers: matchers

        assert_equal :winner, lines.first.level
      end

      def test_it_filters_tagged_lines_by_minimum_level
        lines = [Line.new('foo', :foo),
                 Line.new('bar', :bar),
                 Line.new('baz', :baz)]

        levels = { foo: Level.new(0),
                   bar: Level.new(1),
                   baz: Level.new(2) }

        Processor.filter_lines! lines,
                                levels: levels,
                                min_level: :bar

        assert_equal %w[bar baz], lines.map(&:text)
      end

      def test_it_colorizes_tagged_lines
        lines = [Line.new('foo', :foo),
                 Line.new('bar', :bar),
                 Line.new('baz', :baz)]

        levels = { foo: Level.new(0, :foo, :red),
                   bar: Level.new(1, :bar, :green),
                   baz: Level.new(2, :baz, :blue) }

        Processor.colorize_lines! lines, levels: levels

        assert_equal %W{\e[0;31;49mfoo\e[0m
                        \e[0;32;49mbar\e[0m
                        \e[0;34;49mbaz\e[0m},
                     lines.map(&:text)
      end

      def test_it_renders_lines_to_indented_terminated_strings
        lines = [Line.new('foo'),
                 Line.new('bar'),
                 Line.new('baz')]

        Processor.render_lines! lines, indent_width: 2

        assert_equal ["  foo\n", "  bar\n", "  baz\n"], lines
      end

      def test_it_can_be_initilized_and_run
        log = <<~LOG
          This is generic irrelevant information.
          Hey, I'm warning you, dude. Stuff is gonna get bad.
          This is also a known irrelevant information flood...
            ... telling you that you'd better pay attention to warnings.
          I warned you, dude. Here's an ERROR. :(
        LOG

        levels = { trace:   Level.new(0, :trace),
                   warning: Level.new(1, :warning, :yellow),
                   error:   Level.new(2, :error, :red) }

        matchers = [Matcher.new(/error/i, :error, 1),
                    Matcher.new(/warning/i, :warning, 1),
                    Matcher.new(/flood/, :trace, 2),
                    Matcher.new(//, :trace, 1)]

        my_processor = Processor.new matchers: matchers,
                                     levels: levels,
                                     min_level: :warning,
                                     colorize: true,
                                     indent_width: 4

        assert_equal ["    \e[0;33;49mHey, I'm warning you, dude. Stuff is gonna get bad.\e[0m\n",
                      "    \e[0;31;49mI warned you, dude. Here's an ERROR. :(\e[0m\n"],
                     my_processor.run(log.lines)
      end
    end
  end
end
