require 'mnogootex/version'
require 'mnogootex/configuration'
require 'mnogootex/job'
require 'mnogootex/cli'
require 'mnogootex/runner'
require 'mnogootex/filter'

require 'pathname'

module Mnogootex
  def self.root
    Pathname.new(__dir__).join('mnogootex')
  end
end
