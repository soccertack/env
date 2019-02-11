#!/bin/bash

make ARCH=arm64 columbia_armvirt2_defconfig
time make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j35
