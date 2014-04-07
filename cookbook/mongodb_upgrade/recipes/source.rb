#
# Cookbook Name:: mongodb
# Recipe:: source
#
# Author:: Gerhard Lazu (<gerhard.lazu@papercavalier.com>)
#
# Copyright 2010, Paper Cavalier, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

platform = node[:kernel][:machine]

# Download next version 2.2.0
  # ensuring we have this directory
directory "/usr/src"

remote_file "/usr/src/mongodb-#{node[:mongodb][:nversion]}.tar.tgz" do
  source node[:mongodb][:source]
  #checksum node[:mongodb][platform][:checksum]
  action :create_if_missing
end

bash "Setting up MongoDB #{node[:mongodb][:nversion]}" do
  cwd "/usr/src"
  code <<-EOH
    tar -zxf mongodb-#{node[:mongodb][:nversion]}.tar.gz --strip-components=2 -C #{node[:mongodb][:dir]}/bin
    EOH
end
