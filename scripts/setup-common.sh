#!/bin/bash

ENV_DIR=/tmp/env

pushd $ENV_DIR
sudo ./env.py -n -u root -a
sudo -u jintackl -i -- sh -c 'cd /tmp/env ; /tmp/env/env.py -f -a'
sudo git submodule update --init kvmperf
popd

SCRIPT_DIR=$ENV_DIR/scripts
USR_BIN=/usr/local/bin
BIN_LIST="build-n-install.sh copy-kernel.sh kexec-maxcpus.sh kexec-kernel.sh pin_vcpus.sh qmp-cpus qmp.py"

pushd $SCRIPT_DIR
for f in $BIN_LIST; do
	sudo rm /usr/local/bin/$f
	sudo ln -s $SCRIPT_DIR/$f /usr/local/bin/$f
done
popd

cat $SCRIPT_DIR/keys | sudo tee /root/.ssh/authorized_keys -a

HOSTN=`hostname | cut -d . -f1`
if [ "$HOSTN" == "client-node" ]; then
	EXP_NAME=`uname -a | awk '{print $2}' | cut -d. -f2`

	KEY_DIR=/proj/kvmarm-PG0/jintack/keys/
	sudo mkdir -p $KEY_DIR/$EXP_NAME/
	sudo cp /root/.ssh/id_rsa.pub $KEY_DIR/$EXP_NAME/client-key
fi
