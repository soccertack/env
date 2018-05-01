#!/bin/bash

./mountfs_xen.sh
tar -czf /srv/vm/domu.tar.gz -C /vm .
./unmountfs_xen.sh
