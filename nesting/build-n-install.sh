#!/bin/bash

branch_name=`git symbolic-ref --short HEAD`
LV_DEFAULT=-`echo $branch_name | cut -d"-" -f2-`

if [ -z "$1" ]; then
	read -p "LOCALVERSION?[$LV_DEFAULT]:" LV
	if [ "$LV" == "" ]; then
		LV=$LV_DEFAULT
	fi
else
	LV="$1"
fi

MOD_INSTALL="sudo make modules_install"
if [ -z "$2" ]; then
	echo "Install modules and kernel"
else
	# dummy command
	MOD_INSTALL="ls"
fi

time make -j 40 LOCALVERSION=$LV && $MOD_INSTALL && sudo make install
