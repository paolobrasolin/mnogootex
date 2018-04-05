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
  end
end
