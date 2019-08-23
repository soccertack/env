#!/bin/bash

./setup-nfs-server.sh

pushd /srv/vm
./remove-nested-py
popd

./update-img-dest.sh

