#!/usr/bin/env ruby
#
# Spinup a box, do something cool

require 'fog'
require 'fuggery/rackspace/dns'

module Fuggery
  module Rackspace
    class Spinup
      def initialize user, key, verbose=true
        @compute = Fog::Compute.new({
                                      :provider             => 'rackspace',
                                      :rackspace_username   => user,
                                      :rackspace_api_key    => key,
                                      :version              => :v2,
                                      :rackspace_region     => :lon,
                                      :rackspace_auth_url   => Fog::Rackspace::UK_AUTH_ENDPOINT,
                                    })

        @dns = Fuggery::Rackspace::DNS.new user, key
        @verbose = verbose
      end

      def exists? server_name
        @compute.servers.find {|s| s.name == server_name }
      end

      def rackconnect? server_name
        unless @compute.servers.find {|s| s.name == server_name }.metadata.find {|m| m.key == 'rackconnect_automation_feature_provison_public_ip'}
          return false
        end
        @compute.servers.find {|s| s.name == server_name }.metadata.find {|m| m.key == 'rackconnect_automation_feature_provison_public_ip'}.value == 'ENABLED'
      end

      def log msg
        STDERR.puts("#{Time.now}: #{msg}") if @verbose
      end

      def create server_name, zone, metadata={}
        # Spin up a box if it doesn't exist. Return password
        # We assume that we're not going to be doing anything massively shiny
        flavor = @compute.flavors.find {|f| f.name == '2 GB Performance' }.id
        image  = @compute.images.find {|i| i.name =~ /CentOS 6/ }.id

        if exists? server_name
          log "Host #{server_name} already exists"
          return nil
        end

        srv = @compute.servers.create({
                                        :name      => server_name,
                                        :flavor_id => flavor,
                                        :image_id  => image,
                                        :metadata  => metadata
                                      })
        log "Creating #{server_name}"
        srv.wait_for(300,5) do
          ready?
        end

        # This fails in the above block
        log "Waiting for rackconnect to work on #{server_name}"
        until rackconnect? server_name
          sleep 10
        end

        srv.reload
        ip = srv.ipv4_address

        @dns.a server_name, zone, ip
        %w(web bilcas db redis alpaca codas www api).each do |subdomain|
          log "Creating #{subdomain}.#{server_name} DNS entry"
          @dns.cname "#{subdomain}.#{server_name}", zone, server_name
        end

        return srv.password
      end

      def remove server_name
        if srv = exists?(server_name)
          log "Removing #{server_name}"
          srv.destroy
        end
        log "Removing DNS records attached to #{server_name}"
        @dns.remove_all server_name
      end

    end
  end
end
