#!/usr/bin/env ruby
#
# Spinup a box, do something cool

require 'fog'
require 'fuggery/rackspace/dns'

module Fuggery
  module Rackspace
    class Spinup
      def initialize user, key, zone
        @compute = Fog::Compute.new({
                                      :provider             => 'rackspace',
                                      :rackspace_username   => user,
                                      :rackspace_api_key    => key,
                                      :version              => :v2,
                                      :rackspace_region     => :lon,
                                      :rackspace_auth_url   => Fog::Rackspace::UK_AUTH_ENDPOINT,
                                    })

        @uat_dns = Fuggery::Rackspace::DNS.new user, key, zone
      end

      def exists? server_name
        @compute.servers.find {|s| s.name == server_name }
      end

      def create server_name, metadata={}
        # Spin up a box if it doesn't exist. Return password
        # We assume that we're not going to be doing anything massively shiny
        flavor = @compute.flavors.find {|f| f.name == '2 GB Performance' }.id
        image  = @compute.images.find {|i| i.name =~ /CentOS 6.4/ }.id

        if exists? server_name
          return nil
        end

        srv = @compute.servers.create({
                                        :name      => server_name,
                                        :flavor_id => flavor,
                                        :image_id  => image,
                                        :metadata  => metadata
                                      })
        srv.wait_for(600,5) do
          ready?
        end

        ip = srv.addresses["public"].find{|a| a['version'] == 4}['addr']

        @uat_dns.a server_name, ip
        %w(web bilcas db redis alpaca codas).each do |subdomain|
          @uat_dns.cname "#{subdomain}.#{server_name}", server_name
        end

        return srv.password
      end
    end
  end
end
