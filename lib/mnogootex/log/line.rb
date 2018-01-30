# frozen_string_literal: true

module Mnogootex
  module Log
    Line = Struct.new(:tag, :text) do
      def initialize(tag: nil, text:)
        super(tag&.to_sym, text&.to_s)
      end
    end
  end
end
