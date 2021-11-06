# frozen_string_literal: true

require 'spec_helper'

require 'yaml'

require 'mnogootex/log/processor'

describe Mnogootex::Log::Processor do
  describe '.strings_to_lines!' do
    it 'converts strings into lines' do
      strings = "foo\nbar\n".lines

      described_class.strings_to_lines! strings

      expect(strings).to eq [
        Mnogootex::Log::Line.new('foo'),
        Mnogootex::Log::Line.new('bar')
      ]
    end
  end

  describe '.tag_lines!' do
    it 'tags using short matchers' do
      lines = [Mnogootex::Log::Line.new,
               Mnogootex::Log::Line.new('foo'),
               Mnogootex::Log::Line.new]

      matchers = [Mnogootex::Log::Matcher.new(/foo/, :foo)]

      described_class.tag_lines! lines, matchers: matchers

      expect(lines.map(&:level)).to eq([nil, :foo, nil])
    end

    it 'tags using long matchers' do
      lines = [Mnogootex::Log::Line.new,
               Mnogootex::Log::Line.new,
               Mnogootex::Log::Line.new('foo'),
               Mnogootex::Log::Line.new,
               Mnogootex::Log::Line.new,
               Mnogootex::Log::Line.new,
               Mnogootex::Log::Line.new]

      matchers = [Mnogootex::Log::Matcher.new(/foo/, :foo, 3)]

      described_class.tag_lines! lines, matchers: matchers

      expect(lines.map(&:level)).to eq([nil, nil, :foo, :foo, :foo, nil, nil])
    end

    it 'tags abiding to matchers order' do
      lines = [Mnogootex::Log::Line.new('foo'),
               Mnogootex::Log::Line.new('something')]

      matchers = [Mnogootex::Log::Matcher.new(/foo/, :winner, 1),
                  Mnogootex::Log::Matcher.new(/foo/, :loser, 1),
                  Mnogootex::Log::Matcher.new(//, :anything, 1)]

      described_class.tag_lines! lines, matchers: matchers

      expect(lines.map(&:level)).to eq(%i[winner anything])
    end
  end

  describe '.filter_lines!' do
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

  describe '.colorize_lines!' do
    it 'raises on unknown min level' do
      lines = [Mnogootex::Log::Line.new('foo', :foo)]

      levels = { bar: Mnogootex::Log::Level.new(0) }

      expect do
        described_class.colorize_lines! lines, levels: levels
      end.to raise_exception KeyError
    end

    it 'colorizes tagged lines' do
      lines = [Mnogootex::Log::Line.new('foo', :foo),
               Mnogootex::Log::Line.new('bar', :bar),
               Mnogootex::Log::Line.new('baz', :baz)]

      levels = { foo: Mnogootex::Log::Level.new(0, :foo, :red),
                 bar: Mnogootex::Log::Level.new(1, :bar, :green),
                 baz: Mnogootex::Log::Level.new(2, :baz, :blue) }

      described_class.colorize_lines! lines, levels: levels

      expect(lines.map(&:text)).to eq %W{\e[0;31;49mfoo\e[0m
                                         \e[0;32;49mbar\e[0m
                                         \e[0;34;49mbaz\e[0m}
    end
  end

  describe '.render_lines!' do
    it 'renders lines to indented terminated strings' do
      lines = [Mnogootex::Log::Line.new('foo'),
               Mnogootex::Log::Line.new('bar'),
               Mnogootex::Log::Line.new('baz')]

      described_class.render_lines! lines, indent_width: 2

      expect(lines).to eq ["  foo\n", "  bar\n", "  baz\n"]
    end
  end

  describe '#run' do
    log = <<~LOG
      This is generic irrelevant information.
      Hey, I'm warning you, dude. Stuff is gonna get bad.
      This is also a known irrelevant information flood...
        ... telling you that you'd better pay attention to warnings.
      I warned you, dude. Here's an ERROR. :(
    LOG

    levels = { trace: Mnogootex::Log::Level.new(0, :trace),
               warning: Mnogootex::Log::Level.new(1, :warning, :yellow),
               error: Mnogootex::Log::Level.new(2, :error, :red) }

    matchers = [Mnogootex::Log::Matcher.new(/error/i, :error, 1),
                Mnogootex::Log::Matcher.new(/warning/i, :warning, 1),
                Mnogootex::Log::Matcher.new(/flood/, :trace, 2),
                Mnogootex::Log::Matcher.new(//, :trace, 1)]

    it 'can be initilized and run' do
      my_processor = described_class.new matchers: matchers,
                                         levels: levels,
                                         min_level: :warning,
                                         colorize: true,
                                         indent_width: 4

      expect(my_processor.run(log.lines)).to eq(
        ["    \e[0;33;49mHey, I'm warning you, dude. Stuff is gonna get bad.\e[0m\n",
         "    \e[0;31;49mI warned you, dude. Here's an ERROR. :(\e[0m\n"]
      )
    end

    it 'can disable colorization' do
      my_processor = described_class.new matchers: matchers,
                                         levels: levels,
                                         min_level: :warning,
                                         colorize: false,
                                         indent_width: 4

      expect(my_processor.run(log.lines)).to eq(
        ["    Hey, I'm warning you, dude. Stuff is gonna get bad.\n",
         "    I warned you, dude. Here's an ERROR. :(\n"]
      )
    end

    it 'does not mutate given lines' do
      my_processor = described_class.new matchers: matchers,
                                         levels: levels,
                                         min_level: :warning,
                                         colorize: true,
                                         indent_width: 4

      log_lines = log.lines
      expect { my_processor.run(log_lines) }.to_not(change { log_lines })
    end
  end
end
