#!/bin/bash

branch_name=`git symbolic-ref --short HEAD`
LV_DEFAULT=`echo $branch_name | cut -d"-" -f2-`

# When using vanilla Linux, the branch name looks like heads/v4.20,
# but we don't actually need any localversion for it.
short=$(echo "${LV_DEFAULT}" | head -c6)
if [ $short == "heads/" ]; then
	LV_DEFAULT=""
fi

if [ -z "$1" ]; then
	read -p "LOCALVERSION?[$LV_DEFAULT]:" LV
	if [ "$LV" == "" ]; then
		if [ "$LV_DEFAULT" != "" ]; then
			LV=-$LV_DEFAULT
		else
			LV=""
		fi
	fi
else
	LV="$1"
fi

read -p "make modules_instsall??[y/N]:" MOD
if [ "$MOD" == "y" ]; then
	MOD_INSTALL="sudo make modules_install"
else
	# dummy command
	MOD_INSTALL="ls"
fi

time make -j 40 LOCALVERSION=$LV && $MOD_INSTALL && sudo make install
