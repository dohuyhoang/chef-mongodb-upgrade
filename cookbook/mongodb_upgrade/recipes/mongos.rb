#
# Cookbook Name:: mongodb_upgrade
# Recipe:: default
#
# Copyright 2014, mobile-devices.fr 
#
# All rights reserved - Do Not Redistribute


# Upgrade a mongos instance from 2.0.0 to 2.2.0, Ensure safety by check before running update:
# - Check current db version
# - Check instance is mongos node
# - Check if balancer is disabled
mongos_port = node[:mongodb_upgrade][:mongos][:port]
dbversion = `mongo --port #{mongos_port} --eval 'db.version()'`.lines.to_a.last
if !dbversion.include? node[:mongodb_upgrade][:version]
	Chef::Log.error("The current mongodb has version #{dbversion}. This cookbook only support upgrade from #{node[:mongodb_upgrade][:version]} to 2.2.0")
	fail "Wrong version of mongodb"
end

print "Upgrade mongos from #{dbversion} to #{node[:mongodb_upgrade][:nversion]}"

# Disable balancer 
execute "disable balancer" do
	command "mongo --port #{mongos_port} --eval 'sh.setBalancerState(false)'"
	action :run
end

print "Mongos balancer state: `mongo --port #{mongos_port} --eval 'sh.getBalancerState()`"
# Only perform upgrade if balancer is off
upgrade_binary do 
	service "mongos"
	not_if `mongo --port #{mongos_port} --eval 'sh.getBalancerState()`.include? "true" 

end


