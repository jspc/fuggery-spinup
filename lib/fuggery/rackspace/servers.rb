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
      alias_method :exists?, :server

      def rackconnect? name
        s = server(name)
        unless s.metadata.find {|m| m.key == 'rackconnect_automation_feature_provison_public_ip'}
          return false
        end
        s.metadata.find {|m| m.key == 'rackconnect_automation_feature_provison_public_ip'}.value == 'ENABLED'
      end

      def create server_name, flavor_name, image_name
        return nil if exists? server_name

        flavor = @compute.flavors.find {|f| f.name =~ /#{flavor_name}/ }.id
        image  = @compute.images.find  {|i| i.name =~ /#{image_name}/  }.id
        @compute.servers.create({
                                  :name      => server_name,
                                  :flavor_id => flavor,
                                  :image_id  => image,
                                  :metadata  => {}
                                })
      end

      def remove server_name
        return nil unless exists? server_name
        server(name).destroy
      end
    end
  end
end
