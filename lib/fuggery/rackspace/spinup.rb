#!/usr/bin/env ruby
#
# Spinup a box, do something cool

require 'fog'

module Fuggery
  module Rackspace
    class Spinup
      def initialize user, key
        @compute = Fog::Compute.new({
                                      :provider             => 'rackspace',
                                      :rackspace_username   => user,
                                      :rackspace_api_key    => key,
                                      :version              => :v2,
                                      :rackspace_region     => :lon
                                      :rackspace_auth_url   => Fog::Rackspace::UK_AUTH_ENDPOINT,
                                    })
      end

      def find_or_create server_name, metadata
        # Spin up a box if it doesn't exist. Return IP
        # We assume that we're not going to be doing anything massively shiny
        flavor = @compute.flavors.find {|f| f.name == '1GB Standard Instance' }.id
        image  = @compute.images.find {|i| i.name =~ /CentOS 6.4/ }.id

        unless srv = @compute.servers.find {|s| s.name == server_name }
          srv = @compute.servers.create({ 
                                    :name      => server_name,
                                    :flavor_id => flavor,
                                    :image_id  => image,
                                    :metadata  => metatdata
                                  })
        end
        srv.wait_for(600,5) do
          ready?
        end
        srv.addresses["public"].find{|a| a['version'] == 4}['addr']
      end
    end
  end
end
