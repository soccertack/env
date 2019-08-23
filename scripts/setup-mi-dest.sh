#!/bin/bash

./setup-nfs-client.sh

pushd /srv/vm
./remove-nested-py
popd

./update-img-dest.sh

