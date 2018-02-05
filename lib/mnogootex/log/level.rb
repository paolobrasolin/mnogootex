# frozen_string_literal: true

module Mnogootex
  module Log
    # This data structure represents a log level usually referred to
    # by its {name}. It has a numeric {priority} and a {color} used
    # for rendering.
    #
    # @!attribute priority
    #   @return [Numeric] the numeric priority of the log level
    # @!attribute name
    #   @return [Symbol] the human readable name of the log level
    # @!attribute color
    #   @return [Symbol] the color visually representing the {priority}
    Level = Struct.new(:priority, :name, :color)
  end
end
