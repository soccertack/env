#!/bin/bash

TEST_PATH="~/kvm-unit-test-trap-"$1

for i in `seq 1 10`;
do
	BEGIN=$(sudo cat /sys/kernel/debug/kvm/exits)
	ssh root@10.10.1.100 "cd $TEST_PATH;QEMU=/root/vm/qemu-system-aarch64 ./arm-run arm/selftest.flat" > /dev/null
	END=$(sudo cat /sys/kernel/debug/kvm/exits)
	DIFF=$((END-BEGIN))
	echo $DIFF
done
