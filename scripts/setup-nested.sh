#!/bin/bash

ARCH=`uname -m`
K_VER=${1:-4.15}

echo $1
TMP_FILE=/tmp/env/ver
sudo touch $TMP_FILE
echo "first param" | sudo tee --append $TMP_FILE
echo $1 | sudo tee --append $TMP_FILE
echo "kver" | sudo tee --append $TMP_FILE
echo $K_VER | sudo tee --append $TMP_FILE

if [[ "$ARCH" == "x86_64" ]]; then
	BZ_FILE="/vm/v${K_VER}.img.bz2"
elif [[ "$ARCH" == "aarch64" ]]; then
	BZ_FILE="/vmdata/v${K_VER}.img.bz2"
fi

pushd /tmp/env
sudo ./nested.sh /root $1
popd

