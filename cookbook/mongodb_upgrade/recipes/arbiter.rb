#
# Cookbook Name:: mongodb_upgrade
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute


# Upgrade a mongodb-config instance from 2.0.0 to 2.2.0, Ensure safety by check before running update:
# - Check current db version
# - Check instance is mongod-config node
# - Check if balancer is disabled

port = node[:mongodb_upgrade][:arbiter][:port]

dbversion = `mongo --port #{port} --eval 'db.version()'`.lines.to_a.last

if !dbversion.include? node[:mongodb_upgrade][:version]
	Chef::Log.error("The current mongodb has version #{dbversion}. This cookbook only support upgrade from 2.0.x to 2.2.0")
	fail "Wrong version of mongodb"
end

# Step down if this node is primary node (do it manually)
#node_status = `mongo --port #{port} --eval rs.status()`.match(/\{*#{node[hostname]}*\}/)

#print node_status

upgrade_binary do 
	service "mongodb-arbiter"
end


