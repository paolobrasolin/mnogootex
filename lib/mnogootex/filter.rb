# coding: utf-8

module Mnogootex
  class Filter
    def initialize(filters)
      @error_filters   = filters['error']
      @warning_filters = filters['warning']
      @info_filters    = filters['info']
    end

    def apply(lines)
      lines.map(&:chomp).map! do |line|
        if @error_filters.any? { |regexp| line =~ regexp }
          line.red
        elsif @warning_filters.any? { |regexp| line =~ regexp }
          line.yellow
        elsif @info_filters.any? { |regexp| line =~ regexp }
          line.green
        else
          next
        end
      end.compact.join("\n")
    end
  end
end
