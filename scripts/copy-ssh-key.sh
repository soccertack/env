#!/bin/bash

HOST_KEYS=~/.ssh/authorized_keys
GUEST_KEYS=/root/.ssh/authorized_keys

echo $1 >> $HOST_KEYS
ssh root@10.10.1.100 "echo $1 >> $GUEST_KEYS"
ssh root@10.10.1.101 "echo $1 >> $GUEST_KEYS"
ssh root@10.10.1.102 "echo $1 >> $GUEST_KEYS"
