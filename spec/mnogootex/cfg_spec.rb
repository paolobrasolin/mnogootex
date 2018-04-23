# frozen_string_literal: true

require 'spec_helper'

require 'yaml'
require 'tmpdir'

require 'mnogootex/cfg'

describe Mnogootex::Cfg do
  describe 'load_descending' do
    context 'fake file structure' do
      subject { described_class.load_descending(pathname: Pathname.new('foobar'), basename: 'cfg.yml') }

      it 'raises an error on loading a fake path' do
        expect { subject }.to raise_exception Errno::ENOENT
      end
    end

    context 'real file structure' do
      subject { described_class.load_descending(pathname: tmp_dir.join('A', 'B'), basename: 'cfg.yml') }
      let(:defaults) { { default: true, winner: 'default' } }
      let(:tmp_dir) { Pathname.new(Dir.mktmpdir).join('mnogootex-test') }

      before do
        tmp_dir.join('A', 'B').mkpath
        tmp_dir.join('cfg.yml').write('') # NOTE: empty file
        tmp_dir.join('A', 'cfg.yml').write({ parent: true, winner: 'parent', merged: { deep: true } }.to_yaml)
        tmp_dir.join('A', 'B', 'cfg.yml').write({ child: true, winner: 'child', merged: {} }.to_yaml)
      end

      after do
        tmp_dir.rmtree
      end

      it 'merges paths' do
        expect(subject).to include(:parent)
        expect(subject).to include(:child)
      end

      it 'merges shallowly' do
        expect(subject[:merged]).to_not include(:deep)
      end

      it 'privileges deeper paths' do
        expect(subject[:winner]).to eq('child')
      end

      it 'privileges non defaults' do
        expect(subject[:winner]).to_not eq('default')
      end
    end
  end
end
