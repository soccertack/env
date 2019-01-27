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
BIN_LIST="build-n-install.sh copy-kernel.sh kexec-maxcpus.sh kexec-kernel.sh"

for f in $BIN_LIST; do
	rm /usr/local/bin/$f
	sudo ln -s /tmp/env/$SCRIPT_DIR/$f /usr/local/bin/$f
done

popd

cat /$ENV_PATH/keys | sudo tee /root/.ssh/authorized_keys -a
