#!/bin/bash

ARCH=`uname -m`
ENV_PATH=/tmp/env/nesting

if [[ "$ARCH" == "aarch64" ]]; then

        uname -a | grep -q kvm-node
        err=$?
        if [[ $err == 0 ]]; then
                # kvm node
                source /$ENV_PATH/setup-nested.sh
        else
                # client node
                source /$ENV_PATH/setup-common.sh
        fi
fi

cat /$ENV_PATH/keys | sudo tee /root/.ssh/authorized_keys -a
