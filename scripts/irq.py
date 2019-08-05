#!/usr/bin/python

import os
import sys
import subprocess

stream = os.popen('lscpu')
lines = stream.readlines()
for line in lines:
    sp = line.split()
    if sp[0] == 'CPU(s):':
        cpus = int(sp[1])

raw_input('Press any key to start')
stream = os.popen('cat /proc/interrupts')
before_lines = stream.readlines()

raw_input('press any key to stop')
stream = os.popen('cat /proc/interrupts')
after_lines = stream.readlines()

irq_dict = {}

skip_list = ['CPU0', 'ERR', 'MIS']
for line in before_lines:
    sp = line.split()
    name = sp[0].split(':')

    #Skip the first line
    if name[0] in skip_list:
        continue

    irq_dict[name[0]] = sp[1:]


for line in after_lines:
    sp = line.split()
    name = sp[0].split(':')

    #Skip the first line
    if name[0] in skip_list:
        continue

    after = sp[1:]

    zero = True
    for cpu in range(cpus):
        irq_dict[name[0]][cpu] = int(after[cpu]) - int(irq_dict[name[0]][cpu])
        if irq_dict[name[0]][cpu]:
            zero = False
    
    if zero:
        del irq_dict[name[0]]

for key in irq_dict:
    print irq_dict[key]

#   0:         84          0          0          0          0          0          0          0          0          0  IR-IO-APIC    2-edge      timer

