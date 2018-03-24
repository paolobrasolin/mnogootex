# frozen_string_literal: true

require 'spec_helper'

require 'yaml'

require 'mnogootex/log/processor'

describe Mnogootex::Log::Processor do
  it 'converts strings into lines' do
    strings = "foo\nbar\n".lines

    described_class.strings_to_lines! strings

    expect(strings).to eq [
      Mnogootex::Log::Line.new('foo'),
      Mnogootex::Log::Line.new('bar')
    ]
  end

  it 'tags using short matchers' do
    lines = [Mnogootex::Log::Line.new('foo')]

    matchers = [Mnogootex::Log::Matcher.new(/foo/, :foo)]

    described_class.tag_lines! lines, matchers: matchers

    expect(lines.first.level).to eq(:foo)
  end

  it 'tags using long matchers' do
    lines = [Mnogootex::Log::Line.new('foo'),
             Mnogootex::Log::Line.new('bar'),
             Mnogootex::Log::Line.new('baz')]

    matchers = [Mnogootex::Log::Matcher.new(/foo/, :foo, 3)]

    described_class.tag_lines! lines, matchers: matchers

    expect(lines.map(&:level)).to eq(%i[foo foo foo])
  end

  it 'tags abiding to matchers order' do
    lines = [Mnogootex::Log::Line.new('foo')]

    matchers = [Mnogootex::Log::Matcher.new(/foo/, :winner, 1),
                Mnogootex::Log::Matcher.new(/foo/, :loser, 1)]

    described_class.tag_lines! lines, matchers: matchers

    expect(lines.first.level).to eq(:winner)
  end

  it 'raises on line with unknown level' do
    lines = [Mnogootex::Log::Line.new('foo', :bar)]

    levels = { foo: Mnogootex::Log::Level.new(0) }

    expect do
      described_class.filter_lines! lines,
                                    levels: levels,
                                    min_level: :foo
    end.to raise_exception KeyError
  end

  it 'raises on unknown min level' do
    lines = [Mnogootex::Log::Line.new('foo', :foo)]

    levels = { foo: Mnogootex::Log::Level.new(0) }

    expect do
      described_class.filter_lines! lines,
                                    levels: levels,
                                    min_level: :bar
    end.to raise_exception KeyError
  end

  it 'filters tagged lines by minimum level' do
    lines = [Mnogootex::Log::Line.new('foo', :foo),
             Mnogootex::Log::Line.new('bar', :bar),
             Mnogootex::Log::Line.new('baz', :baz)]

    levels = { foo: Mnogootex::Log::Level.new(0),
               bar: Mnogootex::Log::Level.new(1),
               baz: Mnogootex::Log::Level.new(2) }

    described_class.filter_lines! lines,
                                  levels: levels,
                                  min_level: :bar

    expect(lines.map(&:text)).to eq(%w[bar baz])
  end
end

# module Mnogootex
#   module Log
#     class ProcessorTest < Minitest::Test

#       def test_it_colorizes_tagged_lines
#         lines = [Line.new('foo', :foo),
#                  Line.new('bar', :bar),
#                  Line.new('baz', :baz)]

#         levels = { foo: Level.new(0, :foo, :red),
#                    bar: Level.new(1, :bar, :green),
#                    baz: Level.new(2, :baz, :blue) }

#         Processor.colorize_lines! lines, levels: levels

#         assert_equal %W{\e[0;31;49mfoo\e[0m
#                         \e[0;32;49mbar\e[0m
#                         \e[0;34;49mbaz\e[0m},
#                      lines.map(&:text)
#       end

#       def test_it_renders_lines_to_indented_terminated_strings
#         lines = [Line.new('foo'),
#                  Line.new('bar'),
#                  Line.new('baz')]

#         Processor.render_lines! lines, indent_width: 2

#         assert_equal ["  foo\n", "  bar\n", "  baz\n"], lines
#       end

#       def test_it_can_be_initilized_and_run
#         log = <<~LOG
#           This is generic irrelevant information.
#           Hey, I'm warning you, dude. Stuff is gonna get bad.
#           This is also a known irrelevant information flood...
#             ... telling you that you'd better pay attention to warnings.
#           I warned you, dude. Here's an ERROR. :(
#         LOG

#         levels = { trace:   Level.new(0, :trace),
#                    warning: Level.new(1, :warning, :yellow),
#                    error:   Level.new(2, :error, :red) }

#         matchers = [Matcher.new(/error/i, :error, 1),
#                     Matcher.new(/warning/i, :warning, 1),
#                     Matcher.new(/flood/, :trace, 2),
#                     Matcher.new(//, :trace, 1)]

#         my_processor = Processor.new matchers: matchers,
#                                      levels: levels,
#                                      min_level: :warning,
#                                      colorize: true,
#                                      indent_width: 4

#         assert_equal ["    \e[0;33;49mHey, I'm warning you, dude. Stuff is gonna get bad.\e[0m\n",
#                       "    \e[0;31;49mI warned you, dude. Here's an ERROR. :(\e[0m\n"],
#                      my_processor.run(log.lines)
#       end
#     end
#   end
# end
