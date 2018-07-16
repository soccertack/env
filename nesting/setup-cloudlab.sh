#!/bin/bash

ENV_PATH=/tmp/env/nesting

uname -a | grep -q kvm-
err=$?
if [[ $err == 0 ]]; then
	# kvm node
	source /$ENV_PATH/setup-nested.sh
else
	# client node
	source /$ENV_PATH/setup-common.sh
fi

SCRIPT_DIR=nesting
USR_BIN=/usr/local/bin
pushd /tmp/env/$SCRIPT_DIR
BIN_LIST="build-n-install.sh copy-kernel.sh kexec-maxcpus.sh"
sudo cp $BIN_LIST $USR_BIN
popd

cat /$ENV_PATH/keys | sudo tee /root/.ssh/authorized_keys -a
