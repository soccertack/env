#!/bin/bash

BZ_FILE="/vmdata/v4.15.img.bz2"
# Quit if v4.15.img.bz2 exists
if [ -f $BZ_FILE ]; then
        echo "Initialization is already done"
else
        pushd /tmp/env
        sudo ./env.py -f -u root -a
        sudo ./env.py -f -u jintackl -a
        sudo ./nested.sh /root
        popd
fi
