require 'fog'

module Fuggery
  module Rackspace
    class Servers
      def initialize user, key
        @compute = Fog::Compute.new({
                                      :provider             => 'rackspace',
                                      :rackspace_username   => user,
                                      :rackspace_api_key    => key,
                                      :version              => :v2,
                                      :rackspace_region     => :lon,
                                      :rackspace_auth_url   => Fog::Rackspace::UK_AUTH_ENDPOINT,
                                    })

      end

      def servers
        @compute.servers.map {|s| s.name }
      end

      def server name
        @compute.servers.find {|s| s.name =~ /#{name}/}
      end

      def remove name
        server(name).destroy
      end
    end
  end
end
