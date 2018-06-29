#!/bin/bash

git clone -q https://github.com/soccertack/kvmperf.git /users/jintackl
pushd /tmp/env
sudo ./env.py -f -u root -a
sudo ./env.py -f -u jintackl -a
popd

