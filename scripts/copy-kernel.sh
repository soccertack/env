#!/bin/bash

get_ip()
{
	echo "$1"
	NODE=`echo $1 | cut -d. -f1`
	EXP=`echo $1 | cut -d. -f2`

	if [ "$NODE" == "k" ]; then
		NODE=kvm-node
	elif [ "$NODE" == "d" ]; then
		NODE=kvm-dest
	elif [ "$NODE" == "c" ]; then
		NODE=client-node
	elif [ "$NODE" == "s" ]; then
		NODE=server
	else
		echo "usage: s <node-name>.<exp-name>"
		exit 1
	fi

	TARGET_IP=$NODE.$EXP.kvmarm-pg0.wisc.cloudlab.us
}

if [ -z "$1" ]; then
	echo "Target machine IP?"
	read TARGET_IP
else
	TARGET_IP="$1"
fi

if expr "$TARGET_IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
	echo "success"
else
	get_ip $TARGET_IP
	echo "after conversion: $TARGET_IP"
fi

RELEASE_FILE="include/config/kernel.release"

if [ -f $RELEASE_FILE ]; then
	KERNEL_VER=`cat $RELEASE_FILE`
else
	DEFAULT_KERNEL=`uname -r`
	read -p "Kernel version[$DEFAULT_KERNEL]: " ver
	KERNEL_VER=${ver:-$DEFAULT_KERNEL}
	echo $KERNEL_VER
fi

rsync -av /lib/modules/$KERNEL_VER root@$TARGET_IP:/lib/modules/.
scp /boot/*$KERNEL_VER root@$TARGET_IP:/boot/.

echo "Don't forget to update /etc/default/grub to use a new kernel"
