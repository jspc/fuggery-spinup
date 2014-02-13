#!/usr/bin/env ruby
#
# Update/ set DNS

require 'fog'

module Fuggery
  module Rackspace
    class DNS
      def initialize user, key, zone
        dns = Fog::DNS.new({
                                      :provider             => 'rackspace',
                                      :rackspace_username   => user,
                                      :rackspace_api_key    => key,
                                      :rackspace_region     => :lon,
                                      :rackspace_auth_url   => Fog::Rackspace::UK_AUTH_ENDPOINT,
                                    })
        @zone = dns.zones.find{|z| z.domain == zone}
      end

      def create type, name, ip
        @zone.records.create({
                               :name  => name,
                               :value => ip,
                               :type  => type,
                               :ttl   => 300
                             })
      end

      def a name, ip
        create 'A', name, ip
      end

      def cname name, dst
        create 'CNAME', name, dst
      end

      private :create
    end
  end
end
