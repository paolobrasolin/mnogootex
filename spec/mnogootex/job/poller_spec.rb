# frozen_string_literal: true

require 'spec_helper'
require 'mnogootex/job/poller'

require 'open3'

describe Mnogootex::Job::Poller do
  let(:output) { [] }
  let(:ticks) { [] }
  let(:ticker) { ->(ticks, n) { ticks << [Time.now, n] } }

  def calc_deltas(*array)
    array.each_cons(2).map { |fst, snd| snd - fst }
  end

  it 'waits for lines if runner is alive and stream is empty' do
    _, stream, thread = Open3.popen2e 'sleep 0.4; echo tick'

    start = Time.now
    described_class.new(
      ticker: ticker.curry[ticks],
      throttler: thread.method(:alive?),
      input: stream,
      output: output,
      delay: 0.02
    ).join

    expect(ticks.map(&:last)).to eq([1])

    deltas = calc_deltas start, *ticks.map(&:first)
    deltas.zip([0.4]).each do |measured, expected|
      expect(measured).to be_within(0.05).of(expected)
    end
  end

  it 'throttles lines if runner is alive and stream is full' do
    _, stream, thread = Open3.popen2e 'for i in {1..3}; do echo $i; done; sleep 0.35'

    start = Time.now
    described_class.new(
      ticker: ticker.curry[ticks],
      throttler: thread.method(:alive?),
      input: stream,
      output: output,
      delay: 0.10
    ).join

    expect(output).to eq(%W[1\n 2\n 3\n])
    expect(ticks.map(&:last)).to eq([1,1,1])

    deltas = calc_deltas start, *ticks.map(&:first)
    deltas.zip([0.00, 0.10, 0.10]).each do |measured, expected|
      expect(measured).to be_within(0.05).of(expected)
    end
  end

  it 'chugs lines if runner is dead and if not empty' do
    _, stream, thread = Open3.popen2e 'for i in {1..9}; do echo $i; done'

    thread.join

    start = Time.now
    described_class.new(
      ticker: ticker.curry[ticks],
      throttler: thread.method(:alive?),
      input: stream,
      output: output,
      delay: 0.00
    ).join

    expect(output).to eq(%W[1\n 2\n 3\n 4\n 5\n 6\n 7\n 8\n 9\n])
    expect(ticks.map(&:last)).to eq([9])

    deltas = calc_deltas start, *ticks.map(&:first)
    deltas.zip([0.00, 0.10, 0.10]).each do |measured, expected|
      expect(measured).to be_within(0.05).of(expected)
    end
  end

  it 'does nothing if runner is dead and stream is empty' do
    _, stream, thread = Open3.popen2e ':' # shell noop

    # start = Time.now
    described_class.new(
      ticker: ticker.curry[ticks],
      throttler: thread.method(:alive?),
      input: stream,
      output: output,
      delay: 0.10
    ).join

    expect(output).to eq([])
    expect(ticks.map(&:last)).to eq([])
  end
end
