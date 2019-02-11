#!/bin/bash

OUT=${1:-"exit-analysis.txt"}
echo reset > /sys/kernel/debug/kvm/exit_stats
sleep 10
cat /sys/kernel/debug/kvm/exit_stats > $OUT
