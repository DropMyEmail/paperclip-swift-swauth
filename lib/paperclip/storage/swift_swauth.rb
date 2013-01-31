require File.expand_path(File.join(File.dirname(__FILE__), '..', 'swift', 'swauth_client'))

module Paperclip
  module Storage
    module SwiftSwauth
      def self.extended(base)
      end

      def exists?(style=default_style)
        client.object_exists?(style)
      end

      def flush_writes
        @queued_for_write.each do |style, file|
          write_opts = { content_type: instance_read(:content_type) }
          client.create_object(path(style), write_opts, file)
        end
        after_flush_writes # allows attachment to clean up temp files
        @queued_for_write = {}
      end

      def flush_deletes
      end

      protected

      def client
        if @client.nil?
          @client = Paperclip::Swift::SwauthClient.new
        end
        @client
      end

    end
  end
end
