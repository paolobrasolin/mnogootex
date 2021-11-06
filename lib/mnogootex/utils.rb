# frozen_string_literal: true

require 'digest'

module Mnogootex
  module Utils
    def self.short_md5(input)
      [Digest::MD5.digest(input)]. # get 16 bytes of MD5
        pack('m0'). # pack them into 22+2 base64 bytes (w/o trailing newline)
        tr('+/', '-_'). # make then url/path-safe
        chomp('==') # drop last 2 padding bytes
    end

    def self.humanize_bytes(size)
      %w[b Kb Mb Gb Tb Pb Eb Zb Yb].reduce(size) do |magnitude, unit|
        break "#{magnitude}#{unit}" if magnitude < 1024

        magnitude / 1024
      end
    end

    def self.dir_size(mask)
      Dir.glob(Pathname.new(mask).join('**', '*')).
        map! { |f| Pathname.new(f).size }.inject(:+) || 0
    end
  end
end
