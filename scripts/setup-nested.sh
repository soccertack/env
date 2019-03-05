#!/bin/bash

ARCH=`uname -m`
K_VER=${1:-4.15}

if [[ "$ARCH" == "x86_64" ]]; then
	BZ_FILE="/vm/v${K_VER}.img.bz2"
elif [[ "$ARCH" == "aarch64" ]]; then
	BZ_FILE="/vmdata/v${K_VER}.img.bz2"
fi

# Quit if v4.15.img.bz2 exists
if [ -f $BZ_FILE ]; then
        echo "Initialization is already done"
else
        pushd /tmp/env
        sudo ./nested.sh /root
        popd
fi
