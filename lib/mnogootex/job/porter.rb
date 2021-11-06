# frozen_string_literal: true

require 'pathname'
require 'tmpdir'

require 'mnogootex/utils'

module Mnogootex
  module Job
    class Porter
      attr_reader :hid

      def initialize(hid:, source_path:, work_path: nil)
        @source_path = Pathname.new(source_path).realpath
        @work_path = calc_work_path(work_path).tap(&:mkpath).realpath
        @hid = hid
      end

      def target_dir
        @target_dir ||= @work_path.join(hid)
      end

      def target_path
        @target_path ||= target_dir.join(@source_path.basename)
      end

      def clobber
        target_dir.rmtree if target_dir.directory?
      end

      def provide
        target_dir.mkpath
        providable_files = @source_path.dirname.children
        providable_files.reject!(&@work_path.method(:==))
        FileUtils.cp_r providable_files, target_dir
        target_dir.join('.mnogootex.yml').tap { |p| p.delete if p.file? }
        target_dir.join('.mnogootex.src').make_symlink(@source_path)
      end

      private

      def calc_work_path(path)
        return Pathname.new(path) unless path.nil?

        Pathname.new(Dir.tmpdir).join('mnogootex', source_id)
      end

      def source_id
        @source_id ||= Utils.short_md5(@source_path.to_s)
      end
    end
  end
end
