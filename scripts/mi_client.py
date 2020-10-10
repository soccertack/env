#!/usr/bin/python

import pexpect
import sys
import os
import time
import socket
from datetime import datetime
from sk_common import *
from mi_common import *
import vm_api
import re
from collections import OrderedDict
import csv

#Client status
C_NULL = 0
C_WAIT_FOR_BOOT_CMD = 1
C_BOOT_COMPLETED = 2
C_MIGRATION_COMPLETED = 3
C_TERMINATED = 4

status = C_NULL
monitor_child = None
dest_child = None

def connect_to_server():
    print("Trying to connect to the server")
    clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    try:
        clientsocket.connect(('10.10.1.1', PORT))
    except:
        print ('Not conncted.')
        return None

    print("Connected")
    return clientsocket

workload = ''
keywords = ['total time', 'downtime', 'setup', 'transferred ram', 'throughput',
            'remaining ram', 'total ram', 'duplicate', 'skipped', 'normal',
            'normal bytes', 'dirty sync count', 'page size', 'multifd bytes']
migration_ret = OrderedDict()
migration_ret['workload'] = ['workload']
for k in keywords:
    migration_ret[k] = [k]

def get_migration_info(migration_output):
    for line in migration_output.split('\n'):
        match = re.match(r"([a-z ]+)[: ,]*([0-9.]+)[ ,]*([a-z]*)", line, re.I)
        if match:
            key = match.groups()[0]
            if key in migration_ret:
                migration_ret[key].append(match.groups()[1])

def handle_recv(c, buf):
    global status
    global dest_child
    global workload

    print buf + " is received"
    if status == C_WAIT_FOR_BOOT_CMD:
        if buf == MSG_BOOT:
            vm_api.boot_vms()
            c.send(MSG_BOOT_COMPLETED)
            status = C_BOOT_COMPLETED
    elif status == C_BOOT_COMPLETED:
        if buf != MSG_MIGRATE:
            workload = buf

        if buf == MSG_MIGRATE:
            global monitor_child
            print "start migration"
            child = vm_api.get_child()
            mi_level = vm_api.get_mi_level()

            monitor_child = pexpect.spawn('bash')
            monitor_child.logfile_read=sys.stdout
            monitor_child.timeout=None

            if mi_level == 2:
                monitor_child.sendline('ssh root@10.10.1.100')
                vm_api.wait_for_prompt(monitor_child, vm_api.hostnames[1])

            monitor_child.sendline('telnet 127.0.0.1 4444')
            monitor_child.expect('\(qemu\)')

            child = monitor_child

            #Set migration speed to max for testing
            if vm_api.get_mi_fast():
                child.sendline('migrate_set_speed 4095m')
                child.expect('\(qemu\)')

            if mi_level  == 2:
                child.sendline('migrate -d tcp:10.10.1.110:5555')
            elif mi_level  == 1:
                child.sendline('migrate -d tcp:10.10.1.3:5555')
            else:
                print("Error: mi level is " + int(mi_level))
                sys.exit(1)
            child.expect('\(qemu\)')

            while True:
                time.sleep(10)
                child.sendline('info migrate')
                child.expect('\(qemu\)')
                if "Migration status: completed" in child.before:
                    get_migration_info(child.before)
                    migration_ret['workload'].append(workload)
                    break;

            time.sleep(3)
            print "migration completed"
            c.send(MSG_MIGRATE_COMPLETED)
            status = C_MIGRATION_COMPLETED

            with open("mig.csv", "w") as outfile:
                csvwriter = csv.writer(outfile)
                for key in migration_ret:
                    csvwriter.writerow(migration_ret[key])

            # This is only on the destination
        if buf == MSG_MIGRATE_CHECK:
            mi_level = vm_api.get_mi_level()
            dest_child = pexpect.spawn('bash')
            dest_child.logfile_read=sys.stdout
            dest_child.timeout=None
            vm_api.wait_for_prompt(dest_child, vm_api.hostnames[0])

            if mi_level == 2:
                dest_child.sendline('ssh root@10.10.1.110')
                vm_api.wait_for_prompt(dest_child, vm_api.hostnames[1])

            dest_child.sendline('telnet 127.0.0.1 4445')
            dest_child.expect('Escape character is')

            # Simple tests
            dest_child.sendline()
            vm_api.wait_for_prompt(dest_child, 'L')
            dest_child.sendline('ls')
            vm_api.wait_for_prompt(dest_child, 'L')
            dest_child.sendline('ls')
            vm_api.wait_for_prompt(dest_child, 'L')
            dest_child.sendline('ls -al')
            vm_api.wait_for_prompt(dest_child, 'L')

            c.send(MSG_MIGRATE_CHECKED)
            status = C_MIGRATION_COMPLETED

    if buf == MSG_TERMINATE:
        if monitor_child:
            vm_api.terminate_vms(True, monitor_child)
        elif dest_child:
            vm_api.terminate_vms(False, dest_child)
        else:
            vm_api.terminate_vms(True)
        c.send(MSG_TERMINATED)
        status = C_TERMINATED

reuse_param = False
def main():
    global status
    global reuse_param
    global workload

    vm_api.init(reuse_param)

    rerun = vm_api.get_boolean_input("Want to re-do migration automatically?[y/n]")
    os.system("./setup-nfs-client.sh")
    clientsocket = connect_to_server()
    if not clientsocket:
        sys.exit(0)
    status = C_WAIT_FOR_BOOT_CMD
    workload = ''

    check_vms = vm_api.get_boolean_input("Want to check vm config (i.e. grub)?[y/n]")
    if check_vms:
        vm_api.check_vms()
    while True:
        buf = clientsocket.recv(size)
        if not buf:
            print("Server is disconnected")
            sys.exit(0)
        else:
            handle_recv(clientsocket, buf)
            if status == C_TERMINATED:
                if rerun:
                    reuse_param = True
                    time.sleep(15)
                    print("Reconnect server")
                    status = C_WAIT_FOR_BOOT_CMD
                    workload = ''
                    clientsocket = connect_to_server()
                    if not clientsocket:
                        print("Failed to reconnect server")
                        sys.exit(0)
                else:
                    break

if __name__ == '__main__':
    main()
