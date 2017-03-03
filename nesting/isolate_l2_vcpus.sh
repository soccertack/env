#/bin/bash

for i in `seq 1 10`;
do
	ssh root@10.10.1.100 'cd ~/vm/qemu/scripts/qmp/;./isolate_vcpus.sh'
	sleep 10
done
