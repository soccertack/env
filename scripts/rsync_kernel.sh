#!/bin/bash

KERNEL_VER="4.15.0"
TARGET_IP="128.104.222.81"
INSTALL_PATH="my_modules"

time rsync -av /lib/modules/$KERNEL_VER root@$TARGET_IP:/lib/modules/.
time scp $INSTALL_PATH/*$KERNEL_VER* root@$TARGET_IP:/boot/.
