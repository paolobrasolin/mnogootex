# frozen_string_literal: true

require 'spec_helper'
require 'mnogootex/job/runner'

require 'tmpdir'

describe Mnogootex::Job::Runner do
  let(:test_dir) { Pathname.new(Dir.mktmpdir) }
  before { test_dir.mkpath }
  after { test_dir.rmtree }

  it 'executes commandline in given dir' do
    runner = described_class.new(cl: 'pwd', chdir: test_dir)
    expect(runner).to be_successful
    expect(runner.log_lines.join.chomp).to eq(test_dir.realpath.to_s)
  end

  describe '#alive?' do
    it 'is true if thread is running' do
      runner = described_class.new(cl: 'sleep 0.05', chdir: test_dir)
      expect(runner).to be_alive
    end

    it 'is false if thread is dead' do
      runner = described_class.new(cl: ':', chdir: test_dir)
      sleep 0.05
      expect(runner).to_not be_alive
    end
  end

  describe '#successful?' do
    it 'is true on zero exit status' do
      runner = described_class.new(cl: 'exit 0', chdir: test_dir)
      expect(runner).to be_successful
    end

    it 'is false on nonzero exit status' do
      runner = described_class.new(cl: 'exit 1', chdir: test_dir)
      expect(runner).to_not be_successful
    end
  end

  describe '#count_lines' do
    let!(:lns) { <<~SHELL }
      lns () { i=1; while [ "$i" -le $1 ]; do echo $i; i=$(( i + 1 )); done };
    SHELL

    it 'starts from zero on empty stream' do
      runner = described_class.new(cl: ':', chdir: test_dir)
      expect(runner).to be_successful # waits
      expect(runner.count_lines).to eq(0)
      expect(runner.count_lines).to eq(0)
    end

    it 'starts from zero on full stream' do
      runner = described_class.new(cl: "#{lns} lns 2;", chdir: test_dir)
      expect(runner).to be_successful # waits
      expect(runner.count_lines).to eq(0)
      expect(runner.count_lines).to eq(1)
    end

    it 'increases till lines estimate is reached' do
      runner = described_class.new(cl: "#{lns} lns 3;", chdir: test_dir)
      expect(runner).to be_successful # waits
      expect(runner.count_lines).to eq(0)
      expect(runner.count_lines).to eq(1)
      expect(runner.count_lines).to eq(2)
      expect(runner.count_lines).to eq(3)
    end

    it 'plateaus when lines estimate is reached' do
      runner = described_class.new(cl: "#{lns} lns 2;", chdir: test_dir)
      expect(runner).to be_successful # waits
      expect(runner.count_lines).to eq(0)
      expect(runner.count_lines).to eq(1)
      expect(runner.count_lines).to eq(2)
      expect(runner.count_lines).to eq(2)
    end
  end
end
