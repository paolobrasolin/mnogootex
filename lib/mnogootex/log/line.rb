# frozen_string_literal: true

module Mnogootex
  module Log
    # This data structure represents a log line.
    # It can have a log {level} along with its {text}.
    #
    # @!attribute level
    #   @return [Symbol] the associated log level
    # @!attribute text
    #   @return [String] the contents of the line
    Line = Struct.new(:level, :text)
  end
end
