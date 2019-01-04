#!/bin/bash

ENV_DIR=/tmp/env

KEY_DIR=/proj/kvmarm-PG0/jintack/keys/
git clone -q https://github.com/soccertack/kvmperf.git /users/jintackl
pushd $ENV_DIR
sudo ./env.py -f -u root -a
sudo -u jintackl -i -- sh -c 'cd /tmp/env ; /tmp/env/env.py -f -a'
popd

EXP_NAME=`uname -a | awk '{print $2}' | cut -d. -f2`

sudo mkdir -p $KEY_DIR/$EXP_NAME/
sudo cp /users/jintackl/.ssh/id_rsa.pub $KEY_DIR/$EXP_NAME/client-key
