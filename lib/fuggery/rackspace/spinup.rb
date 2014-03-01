#!/usr/bin/env ruby
#
# Spinup a box, do something cool

require 'fog'
require 'fuggery/rackspace/servers'
require 'fuggery/rackspace/dns'

module Fuggery
  module Rackspace
    class Spinup
      def initialize user, key, verbose=true
        @compute = Fuggery::Rackspace::Servers.new user, key
        @dns     = Fuggery::Rackspace::DNS.new user, key
        @verbose = verbose
      end

      def log msg
        STDERR.puts("#{Time.now}: #{msg}") if @verbose
      end

      def create server_name, flavor, image, zone, subdomains=[]
        if @compute.exists? server_name
          log "Host #{server_name} already exists"
          return nil
        end
        srv = @compute.create server_name, flavor, image

        log "Creating #{server_name}"
        srv.wait_for(300,5) do
          ready?
        end

        ip = srv.ipv4_address
        log "Waiting for rackconnect to work on #{server_name}"
        until @compute.rackconnect? server_name and ip != srv.ip4_address
          sleep 10
          srv.reload
        end
        ip = srv.ipv4_address

        @dns.a server_name, zone, ip
        subdomains.each do |subdomain|
          log "Creating #{subdomain}.#{server_name} DNS entry"
          @dns.cname "#{subdomain}.#{server_name}", zone, server_name
        end

        return srv.password
      end

      def remove server_name
        log "Removing host #{server_name}"
        @compute.remove server_name

        log "Removing DNS records attached to #{server_name}"
        @dns.remove_all server_name
      end

    end
  end
end
