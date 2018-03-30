# frozen_string_literal: true

require 'pathname'
require 'digest'
require 'base64'
require 'tmpdir'

module Mnogootex
  module Job
    class Sitter
      attr_reader :id

      def initialize(id:, source:)
        @source_path = Pathname.new(source) # .realpath
        @id = id
      end

      def target_dir
        @target_dir ||= Pathname.new(Dir.tmpdir).join('mnogootex', source_id, id)
      end

      def setup(target_files_transformer = nil)
        set_down
        set_up
        target_files_transformer&.call(target_path)
      end

      def target_path
        @target_path ||= target_dir.join(@source_path.basename)
      end

      private

      def source_id
        @source_id ||= Base64.urlsafe_encode64 Digest::MD5.digest(@source_path.to_s)
      end

      def set_down
        target_dir.rmtree if target_dir.directory?
        target_dir.mkpath
      end

      def set_up
        # NOTE: can't use Pathname.join here since it elides the dot:
        FileUtils.cp_r File.join(@source_path.dirname, '.'), target_dir
        target_dir.join('.mnogootex.yml').tap { |p| p.delete if p.file? }
        target_dir.join('.mnogootex.src').make_symlink(@source_path)
      end
    end
  end
end
