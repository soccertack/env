#!/bin/sh

CURR=`uname -r`
read -p "kernel:[$CURR]" VER

if [ "$VER" = "" ]; then
	VER="$CURR"
fi

CMD_LINE=`cat /proc/cmdline`

kexec -l /boot/vmlinuz-$VER --initrd=/boot/initrd.img-$VER --command-line="$CMD_LINE"

kexec -e
