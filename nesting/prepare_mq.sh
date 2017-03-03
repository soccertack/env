#!/bin/bash
cd /etc
rm qemu-if*
wget http://www.cs.columbia.edu/~cdall/qemu-ifup
wget http://www.cs.columbia.edu/~cdall/qemu-ifdown
chmod a+x qemu-if*
