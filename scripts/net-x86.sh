#!/bin/bash

#Take an ethernet adapter which has an internal IP address
#(10.10.1.2). Since the ethernet adapter can be changed for
#each reboot, we just search for it instead of hardcode.

for i in `seq 0 3`;
do
	tmp_eth=eth$i
	#https://www.cyberciti.biz/faq/how-to-find-out-the-ip-address-assigned-to-eth0-and-display-ip-only/
	tmp_IP=`ifconfig $tmp_eth | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
	if [[ $tmp_IP == "10.10.1.2" ]]; then
		echo $tmp_eth
		ETH=$tmp_eth
		break
	fi
done

ifconfig $ETH > /dev/null 2>&1
err=$?
if [[ $err != 0 ]]; then
	echo "$ETH not found - are you using the right topology?" >&2
	exit 1
fi

IP=`ifconfig $ETH | grep 'inet addr:' | awk '{ print $2 }' | sed 's/.*://'`
ifconfig $ETH 0.0.0.0
brctl addbr br0
brctl addif br0 $ETH
ifconfig br0 $IP netmask 255.255.255.0
