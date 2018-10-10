#!/bin/bash

ETH_F=`ifconfig | grep "128\." -B1 | head -n 1 | awk '{ print $1 }'`

echo "forward eth: "$ETH_F

brctl addbr xenbr0
ifconfig xenbr0 10.0.0.1 up

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD --in-interface xenbr0 -j ACCEPT
iptables --table nat -A POSTROUTING --out-interface $ETH_F -j MASQUERADE
