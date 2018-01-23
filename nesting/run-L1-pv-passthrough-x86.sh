qemu-system-x86_64 -M q35,accel=kvm -m 12G \
		-cpu host -smp 4 \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device virtio-net-pci,netdev=net0 \
		-device vfio-pci,host=02:00.0,id=net1 \
		-drive file=/vm/l2guest.img,format=raw --nographic
