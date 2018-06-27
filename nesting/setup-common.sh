#!/bin/bash

git clone -q https://github.com/soccertack/kvmperf.git /users/jintackl
pushd /tmp/env
sudo ./env.py -f -u root -a
sudo ./env.py -f -u jintackl -a
popd

SCRIPT_DIR=nesting
USR_BIN=/usr/local/bin
pushd /tmp/env/$SCRIPT_DIR
BIN_LIST="build-n-install.sh copy-kernel.sh"
sudo cp $BIN_LIST $USR_BIN
popd
