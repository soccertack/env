#!/bin/bash
cd /srv/vm/qemu
git remote add qemu git://git.qemu.org/qemu.git
git fetch qemu
git checkout stable-2.10
make -j 20
make install

cd ~
git clone https://github.com/libvirt/libvirt.git -b v3.0.0
apt-get update
apt-get -y install autopoint xsltproc libnl-dev libxml2-dev libyajl-dev libdevmapper-dev libpciaccess-dev
cd libvirt
./autogen.sh --system
make -j20
make install
reboot now
