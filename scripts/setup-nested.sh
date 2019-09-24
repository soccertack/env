#!/bin/bash

ARCH=`uname -m`
K_VER=${1:-4.15}

if [[ "$ARCH" == "x86_64" ]]; then
	BZ_FILE="/vm/v${K_VER}.img.bz2"
elif [[ "$ARCH" == "aarch64" ]]; then
	BZ_FILE="/vmdata/v${K_VER}.img.bz2"
fi

pushd /tmp/env
sudo ./nested.sh /root $1
popd

