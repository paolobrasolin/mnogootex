# frozen_string_literal: true

require 'spec_helper'

require 'tmpdir'

require 'mnogootex/utils'

describe Mnogootex::Utils do
  describe '.short_md5' do
    it 'gives expected hash for empty string' do
      expect(described_class.short_md5('')).to eq('1B2M2Y8AsgTpgAmY7PhCfg')
    end

    it 'gives an url/path-safe hash' do
      expect(described_class.short_md5('Knuth')).to eq('KyIs0ZIec5GkG7_G-clv6Q')
    end
  end

  describe '.humanize_bytes' do
    it 'rounds to smaller unit' do
      expect(described_class.humanize_bytes(1023 * 1024)).to eq('1023Kb')
      expect(described_class.humanize_bytes(1024 * 1024)).to eq('1Mb')
      expect(described_class.humanize_bytes(1025 * 1024)).to eq('1Mb')
    end

    it 'covers a reasonable scale' do
      %w[b Kb Mb Gb Tb Pb Eb Zb Yb].each_with_index do |unit, index|
        expect(described_class.humanize_bytes((2**10)**index)).to eq("1#{unit}")
      end
    end
  end

  describe '.dir_size' do
    let(:tmpdir) { Pathname.new(Dir.mktmpdir) }
    before { tmpdir.mkpath }
    after { tmpdir.rmtree }

    it 'measures an empty dir' do
      expect(described_class.dir_size(tmpdir)).to eq(0)
    end

    # TODO: non-file sizes are os-dependent; find smart way to test
    xit 'measures a subtree' do
      tmpdir.join('foo').write('foo' * 100)
      tmpdir.join('bar').write('bar' * 200)
      tmpdir.join('baz').mkpath # 96 bytes here
      tmpdir.join('baz', 'qux').write('qux' * 300)
      expect(described_class.dir_size(tmpdir.to_s)).to eq(300 + 600 + 96 + 900)
    end
  end
end
