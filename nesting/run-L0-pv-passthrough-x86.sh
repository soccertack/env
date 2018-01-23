#!/bin/bash

NETWORK_IF="virtio-net-pci,bus=pcie.1,netdev=net1,disable-legacy=on,disable-modern=off,iommu_platform=on,ats=on"
NETWORK_IF2="virtio-net-pci,bus=pcie.2,netdev=net2,disable-legacy=on,disable-modern=off,iommu_platform=on,ats=on"
sudo qemu-system-x86_64 -M q35,accel=kvm,kernel-irqchip=split -m 16G \
			-smp 6 -cpu host \
			-device intel-iommu,intremap=on,device-iotlb=on \
			-device ioh3420,id=pcie.1,chassis=1 \
			-device ioh3420,id=pcie.2,chassis=2 \
			-device $NETWORK_IF \
			-netdev tap,id=net1,vhostforce \
			-device $NETWORK_IF2 \
			-netdev tap,id=net2,vhostforce \
			-netdev user,id=net0,hostfwd=tcp::2222-:22 \
			-device virtio-net-pci,netdev=net0 \
			-qmp unix:/var/run/qmp,server,nowait \
			-drive file=/vm/guest0.img,format=raw --nographic


