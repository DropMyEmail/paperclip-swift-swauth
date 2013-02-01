require 'openstack'

module Paperclip
  module Swift
    class SwauthClient
      SERVICE_TYPE = 'object-store'

      def initialize
        @swift_opts = {
          user:      ENV['swift_user'] || '',
          password:  ENV['swift_password'] || '',
          url:       ENV['swift_url'] || '',
          tenant:    ENV['swift_tenant'] || '',
          container: ENV['swift_container'] || ''
        }
      end

      def object_exists?(path)
        container.object_exists? path
      end

      def create_object(path, opts={}, data)
        container.create_object path, opts, data
      end

      def delete_object(path)
        container.delete_object path
      end

      def object(path)
        container.object path
      end

      protected

      def container
        if @connection.nil?
          @connection = OpenStack::Connection.create(connection_opts)
        end
        @connection.container(@swift_opts[:container])
      end

      def connection_opts
        {
          username: @swift_opts[:user],
          api_key: @swift_opts[:password],
          auth_url: @swift_opts[:url],
          authtenant_name: @swift_opts[:tenant],
          auth_method: @swift_opts[:password],
          service_type: SERVICE_TYPE
        }
      end
    end
  end
end
