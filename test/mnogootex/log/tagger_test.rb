require_relative '../../test_helper.rb'

require 'yaml'

require_relative '../../../lib/mnogootex/log/tagger'

module MnogootexTest
  module LogTest
    class TaggerTest < Minitest::Test
      def parsed_tags(yaml, text)
        Mnogootex::Log::Tagger.
          new(YAML.safe_load(yaml, [Regexp, Symbol])).
          parse(text.lines).
          map(&:tag)
      end

      def test_it_tags_simple_matches
        assert_equal %i[foo], parsed_tags(<<~YAML, <<~TEXT)
          - regexp: !ruby/regexp '/^foo/'
            loglvl: !ruby/symbol foo
        YAML
          foo
        TEXT
      end

      def test_it_does_not_rematch_tails
        assert_equal %i[long_bar long_bar], parsed_tags(<<~YAML, <<~TEXT)
          - regexp: !ruby/regexp '/bar/'
            loglvl: !ruby/symbol long_bar
            length: 2
          - regexp: !ruby/regexp '/bar/'
            loglvl: !ruby/symbol short_bar
            length: 1
        YAML
          bar
          bar
        TEXT
      end

      def test_it_applies_matchers_in_order
        assert_equal %i[fast_baz], parsed_tags(<<~YAML, <<~TEXT)
          - regexp: !ruby/regexp '/baz/'
            loglvl: !ruby/symbol fast_baz
          - regexp: !ruby/regexp '/baz/'
            loglvl: !ruby/symbol slow_baz
        YAML
          baz
        TEXT
      end
    end
  end
end
