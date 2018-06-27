#!/bin/sh

if [ -z "$1" ]; then
	echo "Target machine IP?"
	read TARGET_IP
else
	TARGET_IP="$1"
fi

KERNEL_VER=`cat include/config/kernel.release`

TIME_FORMAT="\n%E real\n%U user\n%S sys\n"
time -f "$TIME_FORMAT" rsync -av /lib/modules/$KERNEL_VER root@$TARGET_IP:/lib/modules/.
time -f "$TIME_FORMAT" scp /boot/*$KERNEL_VER root@$TARGET_IP:/boot/.

echo "Don't forget to update /etc/default/grub to use a new kernel"
