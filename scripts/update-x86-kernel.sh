#/bin/bash

if [ $# -eq 0 ] ; then
	echo "Need a target ip addr"
	exit
fi

TARGET_IP=$1
sudo rsync -a /lib/modules/`uname -r` root@$TARGET_IP:/lib/modules/.
scp /boot/*`uname -r`* root@$TARGET_IP:/boot/.

