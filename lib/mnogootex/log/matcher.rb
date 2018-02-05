# frozen_string_literal: true

module Mnogootex
  module Log
    # This data structure represents a typology of log line chunks
    # belonging to a given log {level}.
    # They start with a line matching {regexp} and have a fixed {length}.
    #
    # @!attribute regexp
    #   @return [Regexp] the regexp to match the first line
    # @!attribute level
    #   @return [Symbol] the associated log level
    # @!attribute length
    #   @return [Integer] the number of matched lines
    Matcher = Struct.new(:regexp, :level, :length)
  end
end
