#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'fuggery/rackspace/spinup'

s = Fuggery::Rackspace::Spinup.new ENV['RACKSPACE_USER'], ENV['RACKSPACE_KEY']

server_name = 'my_new_app_server'
metadata = { 
  'project'  => 'fuggery-rackspace-spinup',
  'some_key' => 'some_value'
}

ip, u, pw = s.find_or_create server_name, metadata
puts "Spun up #{server_name}. You can get to it as per: ssh #{u}@#{ip} with password #{pw}"
