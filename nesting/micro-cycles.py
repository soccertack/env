#!/usr/bin/python

import pexpect
import sys
import os
import datetime
import time
import socket

LOCAL_SOCKET = 8890
def pin_l1_vcpus():
	os.system('cd /srv/vm/qemu/scripts/qmp/ && sudo ./pin_vcpus.sh && cd -')
	print ("L1 vcpu is pinned")

def pin_l2_vcpus():
	os.system('ssh root@10.10.1.100 "cd vm/qemu/scripts/qmp/ && ./pin_vcpus.sh"')
	print ("L2 vcpu is pinned")

def pin_vcpus():
	pin_l1_vcpus()
	pin_l2_vcpus()

def boot_vm():
        child.sendline('cd ~ && ./run.sh')

        child.expect('L1.*$')

def boot_nvm():
	boot_vm()
        child.sendline('./run.sh')

        child.expect('L2.*$')
	time.sleep(2)
	pin_vcpus()
	time.sleep(2)

def start_micro():
        child.sendline('cd kvm-unit-test && ./run-micro.sh')

def run_micro():
        child.expect('.*smp 2.*selftest.flat')
	time.sleep(1)
	pin_l2_vcpus()

def reboot():
	
	# Kill VM. (we may do halt -p)
	os.system('pgrep qemu | xargs sudo kill -9')
	time.sleep(2)

	child.expect('kvm-node.*')
	boot_nvm()

child = pexpect.spawn('bash')
child.logfile = sys.stdout
child.timeout=None

child.sendline('')
child.expect('kvm-node.*')
boot_vm()
pin_l1_vcpus()
start_micro()
for x in range(0, 10):
	run_micro()

child.expect('L1.*$')
