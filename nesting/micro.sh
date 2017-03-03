#/bin/bash

$OUTPUT=output

pushd /srv/vm/qemu/scripts/qmp/
sudo ./isolate_vcpus.sh
popd

for i in `seq 1 10`;
do
	ssh root@10.10.1.100 'cd kvm-unit-test;QEMU=/root/vm/qemu-system-aarch64 ./arm-run arm/selftest.flat'
done
