# frozen_string_literal: true

module Mnogootex
  module Log
    Matcher = Struct.new(:regexp, :tag, :length) do
      def initialize(regexp:, tag:, length: 1)
        super(Regexp.new(regexp), tag.to_sym, [length.to_i, 1].max)
      end
    end
  end
end
