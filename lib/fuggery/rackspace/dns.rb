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

      def get_zone zone
        @dns.zones.find{|z| z.domain == zone}
      end

      def create_zone zone, email
        return true if get_zone(zone)
        @dns.zones.create({
                            :domain  => zone,
                            :email   => email,
                          })
      end

      def create_record type, name, zone, ip
        zone = get_zone(zone)
        zone.records.create({
                              :name  => normalize_hostname(name,zone),
                              :value => ip,
                              :type  => type,
                              :ttl   => 300
                            })
      end

      def normalize_hostname name, zone
        name = "#{name}.#{zone}" unless name =~ /#{zone}^/
        name
      end

      def a name, zone, ip
        create_record 'A', name, zone, ip
      end

      def cname name, zone, dst
        create_record 'CNAME', name, zone, dst
      end

      def view name, zone
        get_zone(zone).records.select{|r| r.name =~ /#{name}/ }.map { |r| "#{r.name}. IN #{r.type} #{r.value}" }
      end

      def remove_all fqdn, zone
        get_zone(zone).records.select{|r| r.name =~ /#{fqdn}/ }.each { |r| r.destroy }
        true
      end

      def zones
        @dns.zones.map{|z| z.domain}
      end

    end
  end
end
