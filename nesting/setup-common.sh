#!/bin/bash

KEY_DIR=/proj/kvmarm-PG0/jintack/keys/
sudo touch $KEY_DIR/1
git clone -q https://github.com/soccertack/kvmperf.git /users/jintackl
pushd /tmp/env
sudo touch $KEY_DIR/2
sudo ./env.py -f -u root -a
sudo touch $KEY_DIR/3
sudo ./env.py -f -u jintackl -a
sudo touch $KEY_DIR/4
popd

EXP_NAME=`uname -a | awk '{print $2}' | cut -d. -f2`

KEY_DIR=/proj/kvmarm-PG0/jintack/keys/
sudo mkdir -p $KEY_DIR/$EXP_NAME/
sudo touch $KEY_DIR/6
sudo cp /users/jintackl/.ssh/id_rsa.pub $KEY_DIR/$EXP_NAME/client-key
sudo touch $KEY_DIR/7
