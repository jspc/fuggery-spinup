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

      def create server_name, flavor, image, zone, email, subdomains=[], keyname=nil
        fqdn = @dns.normalize_hostname server_name, zone
        if @compute.exists? fqdn
          log "Host #{fqdn} already exists"
          return nil
        end
        srv = @compute.create fqdn, flavor, image, keyname

        log "Creating #{fqdn}"
        srv.wait_for(300,5) do
          ready?
        end

        ip = srv.ipv4_address
        log "Waiting for rackconnect to work on #{fqdn}"
        until @compute.rackconnect? fqdn and ip != srv.ipv4_address
          sleep 10
          srv.reload
        end
        ip = srv.ipv4_address

        @dns.create_zone zone, email
        @dns.a fqdn, zone, ip
        subdomains.each do |subdomain|
          log "Creating #{subdomain}.#{fqdn} DNS entry"
          @dns.cname "#{subdomain}.#{fqdn}", zone, fqdn
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
