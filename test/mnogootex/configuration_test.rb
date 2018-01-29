require_relative '../test_helper.rb'

module Mnogootex
  class Configuration < Minitest::Test
    def setup
    end

    def test_that_truth_is_true
      assert_equal true, true
    end

    def test_that_whatever_dude
      assert_equal true, false
    end

    def test_that_will_be_skipped
      skip "test this later"
    end
  end
end
