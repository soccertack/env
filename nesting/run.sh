#!/bin/bash
SMP=${1:-6}
MEMSIZE=$((16 * 1024))
cd /srv/vm
sudo ./net.sh
sudo ./run-guest.sh -c $SMP -m $MEMSIZE
reset
