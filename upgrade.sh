#!/bin/bash

# Mobile-Devices 

# Terminate if a command fail
set -e

# Chef ssh username and password to bootstrap
user=root
pass=hoang

# Set hostname of mongodb instances here
mongos=( chefclient1.hoang.fr )
mongodb_config=( chefclient1.hoang.fr )
secondary=( chefclient2.hoang.fr )
primary=chefclient3.hoang.fr
arbiter=chefclient1.hoang.fr


# File info DB (to compare data after upgrading)
data_before=/tmp/mongodb_data_before
data_after=/tmp/mongodb_data_after

# Extract DB info before upgrade 
echo "==================== Prepairing test files ==========================="
for var in "${mongos[@]}"
do
	sshpass -p "$pass" scp export_info.js $user@$var:/tmp
	sshpass -p "$pass" ssh $user@$var "mongo /tmp/export_info.js > $data_before"
done
echo "done"



# Upgrade mongos
echo '==================== Upgrading mongos servers ========================='
for var in "${mongos[@]}"
do
	echo "Bootstrap mongos server $var"
	knife bootstrap $var --ssh-user $user --ssh-password $pass --run-list recipe[mongodb_upgrade::mongos] &
done

# Wait for all mongos upgraded 
FAIL=0
for job in `jobs -p`
do
	echo "waiting for mongos upgrade, pid: $job"
	wait $job || let "FAIL+=1"
done
if [ $FAIL -gt 0 ];
then
	echo "$FAIL mongos instance(s) failed to upgrade. Terminate upgrading process!"
	return 1
fi


# Upgrade config-server
echo "====================== Upgrading config-server ====================="
for var in "${mongodb_config[@]}"
do
	echo "Bootstrap config servers - one by one $var"
        knife bootstrap $var --ssh-user $user --ssh-password $pass --run-list recipe[mongodb_upgrade::config_server]
done


# Upgrade Secondary node
echo "======================= Upgrading secondary node ==================="
for var in "${secondary[@]}"
do
	echo "Bootstrap secondary node $var"
        knife bootstrap $var --ssh-user $user --ssh-password $pass --run-list recipe[mongodb_upgrade::replicaset] &
done

# Wait for all secondary nodes upgraded 
FAIL=0
for job in `jobs -p`
do
        echo "waiting for mongos upgrade, pid: $job"
        wait $job || let "FAIL+=1"
done
if [ $FAIL -gt 0 ];
	then
        echo "$FAIL secondary node(s) failed to upgrade. Terminate upgrading process!"
        return 1
fi
				

# Step down Primary node & prompt user Y/N input
echo "=================== Step down and upgrade primary node ================"
sshpass -p "$pass" ssh $user@$primary "mongo --port 27017 --eval 'rs.stepDown()' | mongo --port 27017 --eval 'printjson(rs.status().members)'"

read -p "Please check on screen, is $primary became secondary? [yn]. If no, step down primary manually" answer
if [[ $answer = y ]] ; then
	# Upgrade Primary node
	echo "Bootstrap primary mongodb node $primary"
	knife bootstrap $primary --ssh-user $user --ssh-password $pass --run-list recipe[mongodb_upgrade::replicaset]
fi

# Upgrade Arbiter node
echo "=========================== Upgrading arbiter node ===================="
echo "Bootstrap arbiter node $primary"
knife bootstrap $arbiter --ssh-user $user --ssh-password $pass --run-list recipe[mongodb_upgrade::arbiter]

# Enable Balancer on mongos
sshpass -p "$pass" ssh $user@${mongos[0]} "mongo --port 27017 --eval 'sh.setBalancerState(true)'"

# Testing data
var=${mongos[0]}
sshpass -p "$pass" ssh $user@$var "mongo /tmp/export_info.js > $data_after"
sshpass -p "$pass" ssh $user@$var "diff $data_before $data_after"



