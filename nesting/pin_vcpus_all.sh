#!/bin/bash
pushd /srv/vm/qemu/scripts/qmp/ && sudo ./pin_vcpus.sh && popd
ssh root@10.10.1.100 "cd vm/qemu/scripts/qmp/ && ./pin_vcpus.sh"


