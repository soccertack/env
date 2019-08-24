#!/usr/bin/python

import pexpect
import sys
import os
import datetime
import time
import socket
import argparse
import os.path
import pickle

class DVH:
    VP = 0
    Vtimer = 1
    VIPI = 2
    Vidle = 3
    Vseg = 4
    VMax = 5

class Params:
	def __init__(self):
		self.level = 0
		self.iovirt = None
		self.posted = False
		mi = None
		mi_role = None
                self.dvh = ['N'] * DVH.VMax

	def __str__(self):
		return str(self.__class__) + ": " + str(self.__dict__)

l0_migration_qemu  = ' --qemu /sdc/L0-qemu/'
l1_migration_qemu = ' --qemu /sdc/L1-qemu/'
mi_src = " -s"
mi_dest = " -t"
LOCAL_SOCKET = 8890
l1_addr='10.10.1.100'
hostname=''
params=None
g_child=None

###############################
#### set default here #########
mi_default = "l2"
io_default = "vp"
###############################
def wait_for_prompt(child):
    child.expect('%s.*#' % hostname)

def pin_vcpus(level):
	os.system('cd /srv/vm/qemu/scripts/qmp/ && sudo ./pin_vcpus.sh && cd -')
	if level > 1:
		os.system('ssh root@%s "cd vm/qemu/scripts/qmp/ && ./pin_vcpus.sh"' % l1_addr)
	if level > 2:
		os.system('ssh root@10.10.1.101 "cd vm/qemu/scripts/qmp/ && ./pin_vcpus.sh"')
	print ("vcpu is pinned")

cmd_pv = './run-guest.sh'
cmd_vfio = './run-guest-vfio.sh'
cmd_viommu = './run-guest-viommu.sh'
cmd_vfio_viommu = './run-guest-vfio-viommu.sh'

def handle_mi_options(vm_level, lx_cmd):

	# For L2 VP migration, we use special QEMUs at L0 and L1
	if vm_level == 1 and params.iovirt == 'vp' and params.mi == "l2":
		lx_cmd += l0_migration_qemu
	
	# This can be checking the last level VM for Ln VP migration...
	if vm_level == 2 and params.iovirt == 'vp' and params.mi == "l2":
		lx_cmd += l1_migration_qemu

	if vm_level == params.level:
		# BTW, this is the only place to use mi_role
		if params.mi_role == "src":
			lx_cmd += mi_src
                elif params.mi_role == "dest":
			lx_cmd += mi_dest

	return lx_cmd

def handle_pi_options(vm_level, lx_cmd):
	# We could support pt as well.
	if vm_level == 1 and params.iovirt == 'vp' and params.posted:
		lx_cmd += " --pi"

	return lx_cmd

def add_special_options(vm_level, lx_cmd):
	lx_cmd = handle_pi_options(vm_level, lx_cmd)
        if params.mi != 'no':
	    lx_cmd = handle_mi_options(vm_level, lx_cmd)

	return lx_cmd

def get_base_cmd(vm_level):
	if vm_level == 1:
		lx_cmd = 'cd /srv/vm && '
	else:
		lx_cmd = 'cd ~/vm && '

	return lx_cmd

def get_iovirt_cmd(vm_level, lx_cmd):
	iovirt = params.iovirt

	if vm_level == 1 and iovirt == "vp":
		lx_cmd += cmd_viommu
	elif iovirt == "vp" or iovirt == "pt":
		if vm_level == params.level:
			lx_cmd += cmd_vfio
		else:
			lx_cmd += cmd_vfio_viommu
	else:
		lx_cmd += cmd_pv

	return lx_cmd

def boot_vms():
	level = params.level
	mi = params.mi
	child = g_child

	vm_level = 0
	while (vm_level < level):
		vm_level += 1

		lx_cmd = get_base_cmd(vm_level)
		lx_cmd = get_iovirt_cmd(vm_level, lx_cmd)
		lx_cmd = add_special_options(vm_level, lx_cmd)
		print (lx_cmd)

		child.sendline(lx_cmd)

		if mi == "l2" and vm_level == 2:
			child.expect('\(qemu\)')
		elif mi == "l1" and vm_level == 1:
			child.expect('\(qemu\)')
		else:
			child.expect('L' + str(vm_level) + '.*$')

	time.sleep(2)
	pin_vcpus(level)
	time.sleep(2)

def halt(level):
    child = g_child

    if level > 2:
        child.sendline('halt -p')
        child.expect('L2.*$')

    if level > 1:
        child.sendline('halt -p')
        child.expect('L1.*$')

    child.sendline('halt -p')
    wait_for_prompt(child)

#depricated for now
def reboot(params):
	halt(params.level)
	boot_nvm(params)

def terminate_vms():
	print ("Terminate VM.")

	child = g_child
	if params.level == 2 and params.mi == 'l2':
		child.sendline('stop')
		child.expect('\(qemu\)')
		child.sendline('q')
		child.expect('L1.*$')
		child.sendline('h')
		wait_for_prompt(g_child)

	if params.level == 1 and params.mi == 'l1':
		child.sendline('stop')
		child.expect('\(qemu\)')
		child.sendline('q')
		wait_for_prompt(g_child)
	
def str_to_bool(s):
	if s == 'True':
		return True
	elif s == 'False':
		return False
	else:
		print (s)
		raise ValueError

EXP_PARAMS_PKL="./.exp_params.pkl"
def set_level():

    level  = int(raw_input("Enter virtualization level (from 1 to 3) [2]: ") or "2")
    if level < 1 or level > 3:
        print ("We only support L1, L2 or L3")
        sys.exit(0)
    return level

def set_iovirt():
    # iovirt: pv, pt(pass-through), or vp(virtual-passthough)
    iovirt = raw_input("Enter I/O virtualization model (pv, pt, or vp) [%s]: " % io_default) or io_default
    if iovirt not in ["pv", "pt", "vp"]:
        print ("Enter pv, pt, or vp")
        sys.exit(0)
    return iovirt

def set_device_pi(iovirt):

    posted = False
    if iovirt == "vp":
        posted = raw_input("Enable posted-interrupts in vIOMMU? [no]: ") or "no"
        if posted == "no":
            posted = False
        else:
            posted = True

    return posted

def set_migration():

    mi_role = ""
    mi = raw_input("Migration? (no, l1, or l2) [%s]: " % mi_default) or mi_default
    if mi not in ["no", "l1", "l2"]:
        print ("Enter no or l1 or l2")
        sys.exit(0)
    elif mi in ["l1", "l2"]:
        if hostname == "kvm-dest":
            mi_role = 'dest'
        else:
            mi_role = 'src'

    return mi, mi_role

def save_params(new_params):
    with open(EXP_PARAMS_PKL, 'wb') as output:
        pickle.dump(new_params, output)

def set_params():
    global params

    exist = os.path.exists(EXP_PARAMS_PKL)
    reuse_param = 'y'
    if exist:
        with open(EXP_PARAMS_PKL, 'rb') as input:
            params = pickle.load(input)
            print(params)

            reuse_param = raw_input("Want to proceed with the params?[y/n] ") or 'y'

    if not exist or reuse_param != 'y':
        new_params = Params()

        new_params.level = set_level()
        new_params.iovirt = set_iovirt()
        new_params.posted = set_device_pi(new_params.iovirt)
        new_params.mi, new_params.mi_role = set_migration()

        save_params(new_params)

        params = new_params

def set_l1_addr():
	global l1_addr
	if hostname == "kvm-dest":
		l1_addr = "10.10.1.110"
	
def create_child():
	global g_child

	child = pexpect.spawn('bash')
	child.logfile_read=sys.stdout
	child.timeout=None

	child.sendline('')
	wait_for_prompt(child)

	g_child = child
	return child

def get_child():
	global g_child
	return g_child

def get_mi_level():
	return params.mi

def init():
	global hostname

	hostname = os.popen('hostname | cut -d . -f1').read().strip()
	set_params()
	set_l1_addr()

	child = create_child()

	return child
