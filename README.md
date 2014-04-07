## Source code for upgrading mongodb 2.0.x to 2.2.0

* Config mongodb params in cookbook/mongodb_upgrade/attributes
* Config servers in upgrade.sh 
* Run upgrade.sh

### Possible bugs
1. mongo shell can't connect to mongos: try force stop mongos and start it again.
