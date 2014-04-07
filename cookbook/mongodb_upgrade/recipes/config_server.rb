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

port = node[:mongodb_upgrade][:config_server][:port]
dbversion = `mongo --port #{port} --eval 'db.version()'`.lines.to_a.last
if !dbversion.include? node[:mongodb_upgrade][:version]
	Chef::Log.error("The current mongodb has version #{dbversion}. This cookbook only support upgrade from 2.0.x to 2.2.0")
	fail "Wrong version of mongodb"
end


# Only perform upgrade if balancer is off
upgrade_binary do 
	service "mongodb-config"
	not_if {balancer_state}.include? "true" 
end


