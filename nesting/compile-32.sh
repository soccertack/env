#!/bin/bash

#https://community.arm.com/soc/b/blog/posts/running-the-latest-linux-kernel-on-a-minimal-arm-cortex-a15-system
make ARCH=arm vexpress_defconfig
#make ARCH=arm columbia-measure_defconfig

time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- LOADADDR=0x80008000 -j35
