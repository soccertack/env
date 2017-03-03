#!/bin/bash

DomU=10.10.1.120
BM=10.10.1.2
KVM=10.10.1.100

servers=("10.10.1.120" "10.10.1.2" "10.10.1.100")
initcwnd=(0 10 30 50 80 100)
route="10.10.1.0/24 dev eth1  proto kernel  scope link  src "

for i in "${servers[@]}"; do
	for j in "${initcwnd[@]}"; do
		CWND=""
		if [[ $j == 0 ]]; then
			CWND=""
		else
			CWND="initcwnd $j"
			ssh root@$i  "ip route change $route $i $CWND"
		fi
		ssh root@$i  "ip route show | grep eth1"
		echo "$i" ": 100 req" "initcwnd: $j">> apache.txt
		sudo ./apache.sh $i 1
		echo "$i" ": 1 req" "initcwnd: $j">> apache.txt
		sudo ./apache_1req.sh $i 1
	done
done 
