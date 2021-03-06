#!/usr/bin/ruby

require 'sling/sling'
require 'sling/users'
include SlingInterface
include SlingSites
include SlingUsers

if $ARGV.size < 1
  puts "Usage: create_site.rb PATH [site groups...]"
  exit 1
end

path = $ARGV[0]
@s = Sling.new()
@sm = SiteManager.new(@s)
@um = UserManager.new(@s)
site = @sm.create_site("sites", "Site #{path}", path)
puts "Site created... making joinable"
site.set_joinable("yes")
if ($ARGV.size > 1)
  groups = $ARGV
  groups.shift
  groups.each do |groupname|
    puts "Creating group #{groupname}"
    group = @um.create_group(groupname)
    site.add_group(group.name)
    "Added group #{group.name}... making joinable"
    group.set_joinable(@s, "yes")
  end
end


