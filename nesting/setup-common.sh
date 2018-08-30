#!/bin/bash

git clone -q https://github.com/soccertack/kvmperf.git /users/jintackl
pushd /tmp/env
sudo ./env.py -f -u root -a
sudo ./env.py -f -u jintackl -a
popd

EXP_NAME=`uname -a | awk '{print $2}' | cut -d. -f2`

KEY_DIR=/proj/kvmarm-PG0/jintack/keys/
sudo mkdir $KEY_DIR/$EXP_NAME/
sudo cp /users/jintackl/.ssh/id_rsa.pub $KEY_DIR/$EXP_NAME/client-key
