# Mobile-Devices 
# Alright reserved
#

define :upgrade_binary, :service => "mongod" do

platform = node[:kernel][:machine]
upgrade_service = params[:service]

# Download next version 2.2.0
tarfile = "mongodb-#{node[:mongodb_upgrade][:nversion]}.tar.tgz"

print "Downloading source file #{node[:mongodb_upgrade][:source]}............."
remote_file "/usr/src/#{tarfile}" do
	source node[:mongodb_upgrade][:source]
	#checksum node[:mongodb_upgrade][platform][:checksum]
	action :create_if_missing
end


# [TEMP] make sure decompress folder exist
directory node[:mongodb_upgrade][:bin] do
	action :create
end

# Shutdown service 
service upgrade_service do
	supports :start => true, :stop => true, "force-stop" => true, :restart => true, "force-reload" => true, :status => true
	action :stop 
end

# Decompress to /usr/bin
bash "Upgrading binary MongoDB #{node[:mongodb_upgrade][:nversion]}" do
	cwd "/usr/src"
	code <<-EOH
	tar -zxf #{tarfile} --strip-components=2 -C #{node[:mongodb_upgrade][:bin]}
	EOH
	only_if {File.exist? ("/usr/src/#{tarfile}")}
end

print "Re-start the service #{upgrade_service}"

# Restart the service
service upgrade_service do
	action [:enable, :start]
end
end
