#!/bin/bash

hostname=`hostname | cut -d . -f1`
if [ $hostname == "client-node" ]; then
    ./mi_server.py
else
    ./mi_client.py
fi
