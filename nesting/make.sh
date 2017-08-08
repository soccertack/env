#!/bin/bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j35
if [ $? == 0 ]; then
	pushd boot-wrapper-aarch64
	./run.sh
	popd
fi
