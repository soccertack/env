#!/bin/bash

echo "hvc avg"
grep hvc $1 | awk '{ print $3 }'

echo "hvc min"
grep hvc $1 | awk '{ print $5 }'

echo "vgic avg"
grep mmio_read_vgic $1 | awk '{ print $3 }'

echo "vgic min"
grep mmio_read_vgic $1 | awk '{ print $5 }'

echo "ipi avg"
grep "ipi:" $1 | awk '{ print $3 }'

echo "ipi min"
grep "ipi:" $1 | awk '{ print $5 }'
