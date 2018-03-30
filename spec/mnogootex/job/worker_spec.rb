# frozen_string_literal: true

require 'spec_helper'
require 'mnogootex/job/worker'

describe Mnogootex::Job::Worker do
  # NOTE: using mktmpdir instead of tmpdir allows parallelization
  let(:test_dir) { Pathname.new(Dir.mktmpdir).join('mnogootex-test') }
  before { test_dir.mkpath }
  after { test_dir.rmtree }

  describe '.new' do
    it 'requires a source' do
      expect { described_class.new id: '1', source: nil }.to raise_exception(TypeError)
    end

    it 'accepts strings' do
      expect { described_class.new id: '1', source: 'foobar' }.to_not raise_exception
    end

    it 'accepts pathnames' do
      expect { described_class.new id: '1', source: Pathname.new('foobar') }.to_not raise_exception
    end
  end

  describe '#target_dir' do
    let(:worker_a1) { described_class.new id: '1', source: test_dir.join('a', 'main.file') }
    let(:worker_a2) { described_class.new id: '2', source: test_dir.join('a', 'main.file') }
    let(:worker_b1) { described_class.new id: '1', source: test_dir.join('b', 'main.file') }

    it 'has a deterministic location' do
      # NOTE: /SYSTMPDIR/mnogootex/URLSAFEBASE64MD5HASH/id
      hash = Base64.urlsafe_encode64(Digest::MD5.digest(test_dir.join('a', 'main.file').to_s))
      expect(worker_a1.target_dir.to_s).
        to match(%r(\A.+/mnogootex/#{hash}/#{1}\z))
    end

    it 'discriminates by id' do
      expect(worker_a1.target_dir).to_not eq(worker_a2.target_dir)
    end

    it 'discriminates by source' do
      expect(worker_a1.target_dir).to_not eq(worker_b1.target_dir)
    end
  end

  describe '#setup' do
    let(:source_path) { test_dir.join('A', 'main.file') }

    before do
      test_dir.join('A', 'B').mkpath
      test_dir.join('A', 'main.file').write('')
      test_dir.join('A', '.mnogootex.yml').write('')
      test_dir.join('A', 'B', 'ancillary.file').write('')
      subject.target_dir.mkpath
      subject.target_dir.join('junk.old').write('')
    end

    subject { described_class.new id: 'job_id', source: source_path }

    context 'given no transformer' do
      before { subject.setup }

      it 'deletes old junk' do
        expect(subject.target_dir.join('junk.old')).to_not exist
      end

      it 'creates target directory' do
        expect(subject.target_dir).to be_directory
      end

      it 'ignores configuration file' do
        expect(subject.target_dir.join('.mnogootex.yml')).to_not exist
      end

      it 'creates link to source' do
        expect(subject.target_dir.join('.mnogootex.src').readlink).to eq(source_path)
      end

      it 'copies all source files' do
        subject.target_dir.join('.mnogootex.src').unlink
        source_path.dirname.join('.mnogootex.yml').unlink
        source_files = source_path.dirname.children.map { |child| child.relative_path_from(source_path.dirname) }
        target_files = subject.target_dir.children.map { |child| child.relative_path_from(subject.target_dir) }
        expect(source_files).to eq(target_files)
      end
    end

    context 'given a transformer' do
      let(:transformer) { ->(target_path) { target_path.unlink } }
      before { subject.setup(transformer) }

      it 'applies transformer' do
        expect(subject.target_dir.join(source_path.basename)).to_not exist
      end
    end
  end

  describe '#start_runner' do
    let(:source_path) { test_dir.join('A', 'main.file') }
    before { source_path.dirname.mkpath }

    subject { described_class.new id: 'job_id', source: source_path }

    context 'given invalid commandline' do
      let(:commandline) { ->(_) { ['foobarbaz'] } }
      before { subject.setup }

      it 'raises' do
        expect { subject.start_runner(commandline) }.to raise_exception(Errno::ENOENT)
      end
    end
  end

  describe '#poller' do
    let(:source_path) { test_dir.join('A', 'main.file') }
    subject { described_class.new id: 'job_id', source: source_path }
    before { source_path.dirname.mkpath }
    before { subject.setup }

    it 'catches stdout' do
      subject.start_runner(->(_) { ['echo message'] }).join
      subject.start_poller(->(_) {}, delay: 0.0).join
      expect(subject.log).to eq ["message\n"]
    end

    it 'catches stderr' do
      subject.start_runner(->(_) { ['echo error 1>&2'] }).join
      subject.start_poller(->(_) {}, delay: 0.0).join
      expect(subject.log).to eq ["error\n"]
    end
  end

  context 'monitoring runner and poller' do
    let(:source_path) { test_dir.join('A', 'main.file') }
    subject { described_class.new id: 'job_id', source: source_path }
    before { source_path.dirname.mkpath }
    before { subject.setup }

    describe '#success?' do
      it 'describes runner success' do
        expect(subject.success?).to be(nil)
        subject.start_runner(->(_) { ['exit 0'] }).join
        expect(subject.success?).to be(true)
      end

      it 'describes runner failure' do
        expect(subject.success?).to be(nil)
        subject.start_runner(->(_) { ['exit 1'] }).join
        expect(subject.success?).to be(false)
      end
    end

    describe '#running?' do
      it 'describes runner lifecycle' do
        expect(subject.running?).to be(nil)
        subject.start_runner(->(_) { ['sleep 0.10'] })
        expect(subject.running?).to be(true)
        subject.runner.join
        expect(subject.running?).to be(false)
      end
    end

    describe '#polling?' do
      it 'describes poller lifecycle' do
        subject.start_runner(->(_) { ['sleep 0.10'] })

        expect(subject.polling?).to be(nil)
        subject.start_poller(->(_) {}, delay: 0.10)
        expect(subject.polling?).to be(true)
        subject.poller.join
        expect(subject.polling?).to be(false)
      end
    end

    describe '#runner' do
      it 'is the runner itself' do
        expect(subject.runner).to be(nil)
        subject.start_runner(->(_) { ['sleep 0.10'] })
        expect(subject.runner).to be_a(Process::Waiter)
      end
    end

    describe '#poller' do
      it 'is the poller itself' do
        subject.start_runner(->(_) { ['sleep 0.10'] })

        expect(subject.poller).to be(nil)
        subject.start_poller(->(_) {}, delay: 0.10)
        expect(subject.poller).to be_a(Thread)
      end
    end
  end
end
