#!/bin/bash

CPU=/sys/devices/system/cpu/cpu
TOTAL_CPUS=`lscpu | egrep "^CPU\(" | awk '{ print $2 }'`
let "TOTAL_CPUS = $TOTAL_CPUS - 1"

lscpu

for i in `seq 1 $TOTAL_CPUS`;
do
	echo 1 > $CPU$i/online
done

lscpu
