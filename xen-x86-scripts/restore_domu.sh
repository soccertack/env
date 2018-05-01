#!/bin/bash

./mountfs_xen.sh
tar -xzf domu.tar.gz -C /vm
./unmountfs_xen.sh
