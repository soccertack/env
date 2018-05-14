#!/bin/bash

ARCH=`uname -m`

if [[ "$ARCH" == "x86_64" ]]; then
	BZ_FILE="/vm/v4.15.img.bz2"
elif [[ "$ARCH" == "aarch64" ]]; then
	BZ_FILE="/vmdata/v4.15.img.bz2"
fi

# Quit if v4.15.img.bz2 exists
if [ -f $BZ_FILE ]; then
        echo "Initialization is already done"
else
        pushd /tmp/env
        sudo ./env.py -f -u root -a
        sudo ./env.py -f -u jintackl -a
        sudo ./nested.sh /root
        popd
fi
