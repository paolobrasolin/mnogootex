require_relative '../test_helper.rb'

require 'yaml'

require 'mnogootex/configuration'

module MnogootexTest
  class Configuration < Minitest::Test
    def setup
      @tmp_dir = Pathname.new(Dir.tmpdir).join('mnogootex-test')
      @tmp_dir.join('A', 'B').mkpath
      @tmp_dir.join('A', 'cfg.yml').write({ parent: true, winner: 'parent', merged: { deep: true } }.to_yaml)
      @tmp_dir.join('A', 'B', 'cfg.yml').write({ child: true, winner: 'child', merged: {} }.to_yaml)

      @cfg = Mnogootex::Configuration.new(basename: 'cfg.yml', defaults: { default: true, winner: 'default' })

      @cfg.load @tmp_dir.join('A', 'B')
    end

    def test_it_merges_paths
      assert_includes @cfg, :parent
      assert_includes @cfg, :child
    end

    def test_it_merges_defaults
      assert_includes @cfg, :default
    end

    def test_it_merges_shallowly
      refute_includes @cfg[:merged], :deep
    end

    def test_it_privileges_deeper_paths
      assert_equal 'child', @cfg[:winner]
    end

    def test_it_privileges_non_defaults
      refute_equal 'default', @cfg[:winner]
    end

    def teardown
      @tmp_dir.rmtree
    end
  end
end
