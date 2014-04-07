### SOURCE PACKAGES
### NOT USED ON CLOUDCONNECT
default[:mongodb_upgrade][:version]           = "2.0"
default[:mongodb_upgrade][:nversion]	      = "2.2.0"
default[:mongodb_upgrade][:source]            = "http://fastdl.mongodb.org/linux/mongodb-linux-#{node[:kernel][:machine]}-#{mongodb_upgrade[:nversion]}.tgz"
default[:mongodb_upgrade][:i686][:checksum]   = "84dc7e3b0ef22b309b993254d759ee4350f6df08b7b10c87594d8b00e4494e22"
default[:mongodb_upgrade][:x86_64][:checksum] = "c1370314d170aafa1df51e553a0955585f45fd46caa164790d41a85731f00131"

### GENERAL
default[:mongodb_upgrade][:dir]         = "/home/mongodb/mongodb-#{mongodb_upgrade[:version]}" 
default[:mongodb_upgrade][:bin]		= "/usr/bin"
default[:mongodb_upgrade][:port]	=	27017
default[:mongodb_upgrade][:mongos][:port]	= 27017
default[:mongodb_upgrade][:config_server][:port] = 27019
default[:mongodb_upgrade][:arbiter][:port]	= 27018
