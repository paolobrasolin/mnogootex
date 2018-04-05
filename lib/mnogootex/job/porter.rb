# frozen_string_literal: true

require 'pathname'
require 'tmpdir'

require 'mnogootex/utils'

module Mnogootex
  module Job
    class Porter
      attr_reader :hid

      def initialize(hid:, source_path:)
        @source_path = Pathname.new(source_path).realpath
        @hid = hid
      end

      def target_dir
        @target_dir ||= Pathname.new(Dir.tmpdir).join('mnogootex', source_id, hid)
      end

      def target_path
        @target_path ||= target_dir.join(@source_path.basename)
      end

      def clobber
        target_dir.rmtree if target_dir.directory?
      end

      def provide
        target_dir.mkpath
        # NOTE: can't use Pathname.join here since it elides the dot:
        FileUtils.cp_r File.join(@source_path.dirname, '.'), target_dir
        target_dir.join('.mnogootex.yml').tap { |p| p.delete if p.file? }
        target_dir.join('.mnogootex.src').make_symlink(@source_path)
      end

      private

      def source_id
        @source_id ||= Utils.short_md5(@source_path.to_s)
      end
    end
  end
end
