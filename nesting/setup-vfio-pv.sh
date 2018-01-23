#!/bin/bash

modprobe vfio-pci
echo 0000:02:00.0 | tee /sys/bus/pci/devices/0000\:02\:00.0/driver/unbind
echo 1af4 1041 | sudo tee /sys/bus/pci/drivers/vfio-pci/new_id
ls /dev/vfio
