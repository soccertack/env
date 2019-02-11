#!/bin/bash

./make.sh && ./update-guest.sh $1
./modules_install_arm.sh
./rsync_kernel_arm.sh $1

