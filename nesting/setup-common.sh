#!/bin/bash

ENV_DIR=/tmp/env

pushd $ENV_DIR
sudo ./env.py -f -u root -a
sudo -u jintackl -i -- sh -c 'cd /tmp/env ; /tmp/env/env.py -f -a'
popd

