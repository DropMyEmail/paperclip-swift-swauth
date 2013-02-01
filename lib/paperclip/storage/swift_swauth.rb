require File.expand_path(File.join(File.dirname(__FILE__), '..', 'swift', 'swauth_client'))

# Public: Paperclip storage adaptor for Openstack Swift.
# Swift authentication is assumed to be on Swauth
module Paperclip
  module Storage
    module SwiftSwauth

      # Public: Hook for the base class to run
      def self.extended(base)
      end

      # Public: Checks that the file exists
      #
      # style - The string which represents the file(default: default_style)
      #
      # Examples
      #
      #   swift_swauth.exists 'foo'
      #   => true
      #
      # Returns a Boolean
      def exists?(style=default_style)
        client.object_exists?(path(style))
      end

      # Public: Performs the write operations stored in the write queue
      #
      # Examples
      #
      #   swift_swauth.flush_writes
      #   => {}
      #
      # Returns nothing
      def flush_writes
        @queued_for_write.each do |style, file|
          write_opts = { content_type: instance_read(:content_type) }
          client.create_object(path(style), write_opts, file)
        end
        after_flush_writes # allows attachment to clean up temp files
        @queued_for_write = {}
      end

      # Public: Performs the delete operations stored in the delete queue
      #
      # Examples
      #
      #   swift_swauth.flush_deletes
      #   => []
      #
      # Returns nothing
      def flush_deletes
        @queued_for_delete.each do |path|
          client.delete_object(path) if client.object_exists?(path)
        end
        @queue_for_delete = []
      end

      # Public: Performs the delete operations stored in the delete queue
      #
      # style           - The string which represents the file
      # local_dest_path - The string which represents the location to save the file to
      #
      # Examples
      #
      #   swift_swauth.copy_to_local_file('foo', '/path/to/foo')
      #   => nil
      #
      # Returns nothing
      def copy_to_local_file(style, local_dest_path)
        if exists?(style)
          local_file = File.open(local_dest_path, 'wb')
          local_file.write(client.object(path(style)).data)
          local_file.close
        end
      end

      protected

      # Private: Returns the swift client for performing the operations
      #
      # Examples
      #
      #   swift_swauth.client
      #   => <Paperclip::Swift::SwauthClient>
      #
      # Returns an instance of SwauthClient
      def client
        if @client.nil?
          @client = Paperclip::Swift::SwauthClient.new
        end
        @client
      end

    end
  end
end
