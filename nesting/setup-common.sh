#!/bin/bash

ENV_DIR=/tmp/env

pushd $ENV_DIR
sudo ./env.py -f -u root -a
sudo -u jintackl -i -- sh -c 'cd /tmp/env ; /tmp/env/env.py -f -a'
popd

SCRIPT_DIR=$ENV_DIR/scripts
USR_BIN=/usr/local/bin
BIN_LIST="build-n-install.sh copy-kernel.sh kexec-maxcpus.sh kexec-kernel.sh"

pushd $SCRIPT_DIR
for f in $BIN_LIST; do
	rm /usr/local/bin/$f
	sudo ln -s $SCRIPT_DIR/$f /usr/local/bin/$f
done
popd

cat $SCRIPT_DIR/keys | sudo tee /root/.ssh/authorized_keys -a
