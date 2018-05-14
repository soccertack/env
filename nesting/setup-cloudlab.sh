#!/bin/bash

ENV_PATH=/tmp/env/nesting

uname -a | grep -q kvm-node
err=$?
if [[ $err == 0 ]]; then
	# kvm node
	source /$ENV_PATH/setup-nested.sh
else
	# client node
	source /$ENV_PATH/setup-common.sh
fi

cat /$ENV_PATH/keys | sudo tee /root/.ssh/authorized_keys -a
