Gem::Specification.new do |s|
  s.name = "fuggery-rackspace-spinup"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["jspc"]
  s.date = "2014-02-24"
  s.description = "Find and Build rackspace servers"
  s.summary = "Rackspace API tools"
  s.email = "jame.condron@fundingcircle.com"
  s.homepage = "https://fundingcircle.com"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "README.md" ,
    "lib/fuggery/rackspace/spinup.rb",
    "lib/fuggery/rackspace/dns.rb",
    "lib/fuggery/rackspace/servers.rb",
    "bin/fuggery-spinup"
  ]
  s.executables = [
    "fuggery-spinup"
  ]
  s.add_dependency( 'fog', '=1.19.0' )
  s.add_dependency( 'unf',  '=0.1.3' )
end
