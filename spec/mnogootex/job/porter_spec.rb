# frozen_string_literal: true

require 'spec_helper'
require 'mnogootex/job/porter'

require 'mnogootex/utils'

describe Mnogootex::Job::Porter do
  # NOTE: using mktmpdir instead of tmpdir allows parallelization
  let(:test_dir) { Pathname.new(Dir.mktmpdir).join('mnogootex-test') }
  before { test_dir.mkpath }
  after { test_dir.rmtree }

  describe '.new' do
    it 'requires a source' do
      expect { described_class.new hid: '1', source_path: nil }.to raise_exception(TypeError)
    end

    it 'requires source to exist' do
      expect { described_class.new hid: '1', source_path: 'foobar' }.to raise_exception(Errno::ENOENT)
    end

    it 'accepts string as source' do
      expect { described_class.new hid: '1', source_path: test_dir.to_s }.to_not raise_exception
    end

    it 'accepts pathname as source' do
      expect { described_class.new hid: '1', source_path: test_dir }.to_not raise_exception
    end
  end

  describe '#target_dir' do
    before do
      test_dir.join('a').mkpath
      test_dir.join('b').mkpath
      test_dir.join('a', 'main.file').write('')
      test_dir.join('b', 'main.file').write('')
    end
    let(:porter_a1) { described_class.new hid: '1', source_path: test_dir.join('a', 'main.file') }
    let(:porter_a2) { described_class.new hid: '2', source_path: test_dir.join('a', 'main.file') }
    let(:porter_b1) { described_class.new hid: '1', source_path: test_dir.join('b', 'main.file') }

    it 'has a deterministic location' do
      hash = Mnogootex::Utils.short_md5(test_dir.join('a', 'main.file').realpath.to_s)
      expect(porter_a1.target_dir.to_s).
        to match(%r{\A.+/mnogootex/#{hash}/#{1}\z})
    end

    it 'discriminates by hid' do
      expect(porter_a1.target_dir).to_not eq(porter_a2.target_dir)
    end

    it 'discriminates by source' do
      expect(porter_a1.target_dir).to_not eq(porter_b1.target_dir)
    end
  end

  describe '#target_path' do
    let(:source_path) { test_dir.join('a', 'main.file') }
    let(:porter) { described_class.new hid: '1', source_path: source_path }

    before do
      source_path.dirname.mkpath
      source_path.write('')
    end

    it 'rescopes source basename into target dirname' do
      expect(porter.target_path.basename).to eq(source_path.basename)
      expect(porter.target_path.dirname).to eq(porter.target_dir)
    end
  end

  describe '#provide' do
    let(:source_path) { test_dir.join('A', 'main.file') }

    before do
      test_dir.join('A', 'B').mkpath
      test_dir.join('A', 'main.file').write('')
      test_dir.join('A', '.mnogootex.yml').write('')
      test_dir.join('A', '.dotfile').write('')
      test_dir.join('A', 'B', 'ancillary.file').write('')
    end

    subject { described_class.new hid: 'job_id', source_path: source_path }

    it 'creates target directory' do
      subject.provide
      expect(subject.target_dir).to be_directory
    end

    it 'ignores configuration file' do
      test_dir.join('A', '.mnogootex.yml').unlink
      subject.provide
      expect(subject.target_dir.join('.mnogootex.yml')).to_not exist
    end

    it 'creates link to source' do
      subject.provide
      expect(subject.target_dir.join('.mnogootex.src').readlink).to eq(source_path.realpath)
    end

    def relative_subtree(pathname)
      Pathname.glob(pathname.join('**', '{.*,*}')).map do |child|
        child.relative_path_from(pathname)
      end
    end

    it 'copies all source files' do
      subject.provide
      subject.target_dir.join('.mnogootex.src').unlink
      source_path.dirname.join('.mnogootex.yml').unlink
      # NOTE: unlinking so comparison is easier to write
      expect(relative_subtree(source_path.dirname)).
        to eq(relative_subtree(subject.target_dir))
    end
  end

  describe '#clobber' do
    let(:source_path) { test_dir.join('A', 'main.file') }

    before do
      test_dir.join('A', 'B').mkpath
      test_dir.join('A', 'main.file').write('')
    end

    subject { described_class.new hid: 'job_id', source_path: source_path }

    it 'cleans up target dir if it exists' do
      subject.provide
      expect(subject.target_dir).to exist
      subject.clobber
      expect(subject.target_dir).to_not exist
    end

    it 'does nothing if target dir does not exist' do
      expect(subject.target_dir).to_not exist
      expect { subject.clobber }.to_not raise_exception
    end
  end
end
