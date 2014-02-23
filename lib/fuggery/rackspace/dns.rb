#!/usr/bin/env ruby
#
# Update/ set DNS

require 'fog'

module Fuggery
  module Rackspace
    class DNS
      def initialize user, key
        @dns = Fog::DNS.new({
                                      :provider             => 'rackspace',
                                      :rackspace_username   => user,
                                      :rackspace_api_key    => key,
                                      :rackspace_region     => :lon,
                                      :rackspace_auth_url   => Fog::Rackspace::UK_AUTH_ENDPOINT,
                                    })
      end

      def create type, name, zone, ip
        zone = @dns.zones.find{|z| z.domain == zone}
        zone.records.create({
                              :name  => name,
                              :value => ip,
                              :type  => type,
                              :ttl   => 300
                            })
      end

      def a name, zone, ip
        create 'A', name, zone, ip
      end

      def cname name, zone, dst
        create 'CNAME', name, zone, dst
      end

      def view name, zone
        @dns.zones.find{|z| z.domain == zone}.records.select{|r| r.name =~ /#{name}/ }.map { |r| "#{r.name}. IN #{r.type} #{r.value}" }
      end

      def remove_all name, zone
        @dns.zones.find{|z| z.domain == zone}.records.select{|r| r.name =~ /#{name}/ }.each { |r| r.destroy }
        true
      end

      def zones
        @dns.zones.map{|z| z.domain}
      end

      private :create
    end
  end
end
