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

class Params:
	def __init__(self):
		self.level = 2
		self.iovirt = 'pv'
		self.posted = False
		self.mi = False
		self.mi_level = 0
		self.mi_role = None
		self.mi_fast = False
                self.smp = True
                self.small_memory = False
                self.dvh =  {
                            'virtual_ipi': 'n',
                            'virtual_timer': 'n',
                            'virtual_idle': 'n',
                            'fs_base': 'n',
                            }
		self.dvh_use = False
	
	def __str__(self):
		print ("SMP: " + str(self.smp))
		print ("Small memory: " + str(self.small_memory))
		print ("Level: " + str(self.level))
		print ("I/O virtualization: " + self.iovirt)
		if self.iovirt == 'vp':
			print ("Device PI: " + str(self.posted))

                if self.mi:
                    print ("Migration level: %d as %s. Fast: %s" % (self.mi_level, self.mi_role, str(self.mi_fast)))

                for d in self.dvh:
                    print("%s: %s" % (d, self.dvh[d]))

mi_src = " -s"
mi_dest = " -t"
LOCAL_SOCKET = 8890
l1_addr='10.10.1.100'
PIN = ' -w'
pin_waiting='waiting for connection.*server'
hostname = os.popen('hostname | cut -d . -f1').read().strip()
hostnames = []
hostnames.append(hostname)
hostnames += ['L1', 'L2', 'L3']
params=None
g_child=None

###############################
#### set default here #########
mi_default = "l2"
io_default = "vp"
###############################
def wait_for_prompt(child, hostname):
    child.expect('%s.*#' % hostname)

def pin_vcpus(level):

        if level == 1:
	    os.system('cd /usr/local/bin/ && sudo ./pin_vcpus.sh && cd -')
	if level == 2:
		os.system('ssh root@%s "cd vm/qemu/scripts/qmp/ && ./pin_vcpus.sh"' % l1_addr)
	if level == 3:
		os.system('ssh root@10.10.1.101 "cd vm/qemu/scripts/qmp/ && ./pin_vcpus.sh"')
	print ("vcpu is pinned")

cmd_pv = './run-guest.sh'
cmd_vfio = './run-guest-vfio.sh'
cmd_viommu = './run-guest-viommu.sh'
cmd_vfio_viommu = './run-guest-vfio-viommu.sh'

def handle_mi_options(vm_level, lx_cmd):
        if vm_level == params.mi_level:
		# BTW, this is the only place to use mi_role
		if params.mi_role == "src":
			lx_cmd += mi_src
                if params.mi_role == "dest":
			lx_cmd += mi_dest

	return lx_cmd

def handle_pi_options(vm_level, lx_cmd):
	# We could support pt as well.
	if vm_level == 1 and params.iovirt == 'vp' and params.posted:
		lx_cmd += " --pi"

	return lx_cmd

def add_dvh_options(vm_level, lx_cmd):
    # WIP: we are supporting QEMU DVH support for L1 for now
    if vm_level != 1:
        return lx_cmd

    if params.dvh['virtual_timer'] == 'y':
        lx_cmd += ' -p -dvh-vtimer'

    return lx_cmd

def add_special_options(vm_level, lx_cmd):
	lx_cmd = handle_pi_options(vm_level, lx_cmd)
        if params.mi:
	    lx_cmd = handle_mi_options(vm_level, lx_cmd)

        lx_cmd += PIN

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

def configure_dvh(vm_level):
    child = g_child

    for f in params.dvh:
	# We never set virtual idle for L1
	if vm_level == 1 and f == 'virtual_idle':
		continue;

        # WIP: We don't use cmd line option for vtimer for L1
	if vm_level == 1 and f == 'virtual_timer':
		continue;

        dvh_filename='/sys/kernel/debug/dvh/' + f
        cmd = 'echo %s > %s' % (params.dvh[f], dvh_filename)
        child.sendline(cmd)
        # Wait for host prompt
        wait_for_prompt(child, hostnames[vm_level - 1])

def boot_vms():
    level = params.level
    mi_level = params.mi_level
    child = g_child

    vm_level = 0

    mem = 3
    while (vm_level < level):
        vm_level += 1

        lx_cmd = get_base_cmd(vm_level)
        lx_cmd = get_iovirt_cmd(vm_level, lx_cmd)
        lx_cmd = add_special_options(vm_level, lx_cmd)
        lx_cmd = add_dvh_options(vm_level, lx_cmd)
	if not params.smp:
		lx_cmd += ' -c 1 '
	if params.small_memory:
		lx_cmd += ' -m %d ' % mem
		mem -= 1
        print (lx_cmd)

        configure_dvh(vm_level)

        child.sendline(lx_cmd)
        child.expect(pin_waiting)
        pin_vcpus(vm_level)

        if mi_level == vm_level and params.mi_role == 'dest' :
            child.expect('\(qemu\)')
            break
        else:
            child.expect('L' + str(vm_level) + '.*$')

def halt(level):
    child = g_child

    if level > 2:
        child.sendline('halt -p')
        child.expect('L2.*$')

    if level > 1:
        child.sendline('halt -p')
        child.expect('L1.*$')

    child.sendline('halt -p')
    wait_for_prompt(child, hostname)

#depricated for now
def reboot(params):
	halt(params.level)
	boot_nvm(params)

def terminate_vms(qemu_monitor, child = None):
	global g_child
	print ("Terminate VM.")

	if not child:
		child = g_child

	if qemu_monitor:
		if params.level == 2 and params.mi_level == 2:
			child.sendline('stop')
			child.expect('\(qemu\)')
			child.sendline('q')
			child.expect('L1.*$')
			child.sendline('h')
			wait_for_prompt(g_child, hostname)

		if params.level == 1 and params.mi_level == 1:
			child.sendline('stop')
			child.expect('\(qemu\)')
			child.sendline('q')
			wait_for_prompt(g_child, hostname)

	else:
            for i in reversed(range(params.level)):
                child.sendline('halt -p')
                wait_for_prompt(child, hostnames[i])
	
def str_to_bool(s):
	if s == 'True':
		return True
	elif s == 'False':
		return False
	else:
		print (s)
		raise ValueError

EXP_PARAMS_PKL="/root/.exp_params.pkl"
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

def get_boolean_input(statement):

    while True:
        try:
            return {'y':True, 'n':False, '':False}[raw_input(statement).lower()]
        except KeyError:
            print "Invalid input please enter y, Y, n, or N"

def get_yn_input(statement):

    while True:
        try:
            return {'y':'y', 'n':'n'}[raw_input(statement).lower()]
        except KeyError:
            print "Invalid input please enter y, Y, n, or N"

def get_int_input(statement):

    while True:
        try:
            return int(raw_input(statement))
        except ValueError:
            print "Invalid input. Please enter integer"

def set_smp():
    return get_boolean_input("SMP [y/n]?: ")

def set_smallmemory():
    return get_boolean_input("Small memory[y/n]?: ")

def set_migration(new_params):

    new_params.mi = get_boolean_input("Migration [y/N]?: ")

    if not new_params.mi:
        return

    new_params.mi_level = int(raw_input("Migration level (from 1 to 3) [2]: ") or "2")
    if new_params.level < 1 or new_params.level > 3:
        print ("We only support L1, L2 or L3")
        sys.exit(0)

    if hostname == "kvm-node":
        new_params.mi_fast = get_boolean_input("Fast migration speed [y/N]?: ")

    if hostname == "kvm-dest":
        new_params.mi_role = 'dest'
    else:
        new_params.mi_role = 'src'

def save_params(new_params):
    with open(EXP_PARAMS_PKL, 'wb+') as output:
        pickle.dump(new_params, output)

def set_dvh(new_params):

    dvh = raw_input("DVH [y/N]?: ") or 'n'

    if dvh == 'n':
	new_params.dvh_on = False
        return

    new_params.dvh_on = True
    for f in new_params.dvh:
        enable = raw_input("DVH %s [y/N]?: " % f) or 'n'
        new_params.dvh[f] = enable

SMP = 1
SmallMemory = 2
LEVEL = 3
IO = 4
PI = 5
DVH_TIMER = 6
DVH_IPI = 7
DVH_IDLE = 8
FS_BASE = 9
MIGRAION = 10
MI_LEVEL = 11
MI_SPEED = 12

def print_params():
    print("%d. [%s] SMP" % (SMP, str(params.smp)))
    print("%d. [%s] SmallMemory" % (SmallMemory, str(params.small_memory)))
    print("%d. [%s] Virtualization Level" % (LEVEL, params.level))
    print("%d. [%s] I/O virtualization model (pv, pt, or vp)" % (IO, params.iovirt))
    if params.iovirt == 'vp':
        print("%d. [%s] Device PI" % (PI, str(params.posted)))

    print("%d. [%s] Virtual timer" % (DVH_TIMER, str(params.dvh['virtual_timer'])))
    print("%d. [%s] Virtual ipi" % (DVH_IPI, str(params.dvh['virtual_ipi'])))
    print("%d. [%s] Virtual idle" % (DVH_IDLE, str(params.dvh['virtual_idle'])))
    print("%d. [%s] FS_BASE fix" % (FS_BASE, str(params.dvh['fs_base'])))

    print("%d. [%s] Migration" % (MIGRAION, str(params.mi)))
    if params.mi:
        print("%d. [%s] Migration level" % (MI_LEVEL, str(params.mi_level)))
        if hostname == "kvm-node":
            print("%d. [%s] Fast migration" % (MI_SPEED, str(params.mi_fast)))

def update_params():
    global params

    num = int(raw_input("Enter number to update configuration. Enter 0 to finish: ") or "0")

    if num == 0:
        return False
    if num == SMP:
        params.smp = get_boolean_input("y/n: ")
    if num == SmallMemory:
        params.small_memory = get_boolean_input("y/n: ")
    if num == LEVEL:
        params.level = get_int_input("Input 1, 2, or 3 ")
    if num == IO:
        params.iovirt = raw_input("pv, pt, or vp: ")
        if params.iovirt == 'vp':
            params.posted = get_boolean_input("Device PI y/n: ")
    if num == PI:
        params.posted = get_boolean_input("y/n: ")

    if num == DVH_TIMER:
        params.dvh['virtual_timer'] = get_yn_input("y/n: ")
    if num == DVH_IPI:
        params.dvh['virtual_ipi'] = get_yn_input("y/n: ")
    if num == DVH_IDLE:
        params.dvh['virtual_idle'] = get_yn_input("y/n: ")
    if num == FS_BASE:
        params.dvh['fs_base'] = get_yn_input("y/n: ")

    if num == MIGRAION:
        params.mi = get_boolean_input("y/n: ")
        if params.mi:
            params.mi_level = get_int_input("Migration level: Input 1, 2, or 3: ")

            if hostname == "kvm-node":
                params.mi_fast = get_boolean_input("Fast migration speed [y/N]?: ")

            if hostname == "kvm-dest":
                params.mi_role = 'dest'
            else:
                params.mi_role = 'src'

    if num == MI_LEVEL:
        params.mi_level = get_int_input("Input 1, 2, or 3: ")

    if num == MI_SPEED:
        if hostname == "kvm-node":
            params.mi_fast = get_boolean_input("Fast migration speed [y/N]?: ")

    return True 

def set_params(reuse_force):
    global params

    exist = os.path.exists(EXP_PARAMS_PKL)
    reuse_param = 'y'
    if exist:
        with open(EXP_PARAMS_PKL, 'rb') as input:
            params = pickle.load(input)

    if (not exist) or (not reuse_force):

        if not params:
            params = Params()

        update = True
        while update:
            print_params()
            update = update_params()
            new_params = Params()

        save_params(params)


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
	wait_for_prompt(child, hostname)

	g_child = child
	return child

def get_child():
	global g_child
	return g_child

def get_mi_level():
	return params.mi_level

def get_mi_fast():
	return params.mi_fast

def init(reuse_param):

	set_params(reuse_param)
	set_l1_addr()

	child = create_child()

	return child
