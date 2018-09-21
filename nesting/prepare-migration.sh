#!/bin/bash
sudo apt-get update
sudo apt-get install nfs-common
mount 10.10.1.1:/sdc /sdc
df -h
