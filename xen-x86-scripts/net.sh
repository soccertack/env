#!/bin/bash

ETH=`ifconfig | grep "10\.10\." -B1 | head -n 1 | awk '{ print $1 }'`

echo "private network eth: "$ETH
./net_forward.sh

ifconfig $ETH > /dev/null 2>&1
err=$?
if [[ $err != 0 ]]; then
	echo "eth2 not found - are you using the right topology?" >&2
	exit 1
fi

IP=`ifconfig $ETH | grep 'inet addr:' | awk '{ print $2 }' | sed 's/.*://'`
ifconfig $ETH 0.0.0.0
brctl addbr xenbr1
brctl addif xenbr1 $ETH
ifconfig xenbr1 $IP netmask 255.255.255.0

sed -i '/vif =/d' domU.conf

echo "vif = ['bridge=xenbr0,ip=10.0.0.4,mac=de:ad:be:ef:89:ca', 'bridge=xenbr1,ip=10.10.1.120,mac=de:ad:be:ef:15:de']" >> domU.conf
