#!/bin/bash

option=$1
add=$2 # 0 for remove, 1 for add

GRUB_HEAD="GRUB_CMDLINE_LINUX_DEFAULT=\""
GRUB_FILE='/etc/default/grub'

grep -q "^$GRUB_HEAD.*$option" $GRUB_FILE
err=$?
if [[ $err == 0 ]]; then
	echo $option" found"
	if [[ $add == 0 ]]; then
		sed -i "s/$option *//" $GRUB_FILE
	fi

else
	echo "No $option found"
	if [[ $add == 1 ]]; then
		sed -i "s/^$GRUB_HEAD/${GRUB_HEAD}${option} /" $GRUB_FILE
	fi
fi

grep ^$GRUB_HEAD $GRUB_FILE
update-grub
