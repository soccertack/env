#!/bin/sh

read -p "maxcpus=" MAX_CPUS

CMD_LINE=`cat /proc/cmdline`
echo $CMD_LINE
CMD_LINE=`cat /proc/cmdline | sed "s/maxcpus=[0-9]*/maxcpus=$MAX_CPUS/"`
echo $CMD_LINE

kexec -l /boot/vmlinuz-4.15.0-kexec --initrd=/boot/initrd.img-4.15.0-kexec --command-line="$CMD_LINE"

kexec -e
