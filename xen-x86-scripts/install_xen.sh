#!/bin/bash

git clone git://xenbits.xen.org/xen.git
apt-get update
apt-get build-dep xen -y

pushd xen
git checkout RELEASE-4.10.1
./configure
make install-xen -j 10
make install-tools -j 10
/sbin/ldconfig
update-grub
update-rc.d xencommons defaults 19 18 

popd

