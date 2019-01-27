#!/bin/sh

read -p "maxcpus=" MAX_CPUS

CMD_LINE=`cat /proc/cmdline`
echo $CMD_LINE
CMD_LINE=`cat /proc/cmdline | sed "s/maxcpus=[0-9]*/maxcpus=$MAX_CPUS/"`
echo $CMD_LINE

VER=`uname -r`

kexec -l /boot/vmlinuz-$VER --initrd=/boot/initrd.img-$VER --command-line="$CMD_LINE"

kexec -e
