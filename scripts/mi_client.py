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

#Client status
C_NULL = 0
C_WAIT_FOR_BOOT_CMD = 1
C_BOOT_COMPLETED = 2
C_MIGRATION_COMPLETED = 3
C_TERMINATED = 4

status = C_NULL
monitor_child = None

def connect_to_server():
	print("Trying to connect to the server")
	clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

	while True:
		try:
			clientsocket.connect(('10.10.1.1', PORT))
			break;
		except:
			print ('connect error. Try again')
			time.sleep(1)


	print("Connected")
	return clientsocket

def handle_recv(c, buf):
	global status

	print buf + " is received"
	if status == C_WAIT_FOR_BOOT_CMD:
		if buf == MSG_BOOT:
			vm_api.init()
			vm_api.boot_vms()
			c.send(MSG_BOOT_COMPLETED)
			status = C_BOOT_COMPLETED
	elif status == C_BOOT_COMPLETED:
		if buf == MSG_MIGRATE:
			global monitor_child
			print "start migration"
			child = vm_api.get_child()
			mi_level = vm_api.get_mi_level()
#			child.sendline('migrate_set_speed 4095m')
#			child.expect('\(qemu\)')

			monitor_child = pexpect.spawn('bash')
			monitor_child.logfile_read=sys.stdout
			monitor_child.timeout=None
                        
                        if mi_level == 2:
		    	    monitor_child.sendline('ssh root@10.10.1.100')
                            vm_api.wait_for_prompt(monitor_child, vm_api.hostnames[1])

			monitor_child.sendline('telnet 127.0.0.1 4444')
			monitor_child.expect('\(qemu\)')
			child = monitor_child
			if mi_level  == 2:
				child.sendline('migrate -d tcp:10.10.1.110:5555')
			elif mi_level  == 1:
				child.sendline('migrate -d tcp:10.10.1.3:5555')
			else:
				print("Error: mi level is " + mi_level)
				sys.exit(1)
			child.expect('\(qemu\)')

			while True:
				time.sleep(10)
				child.sendline('info migrate')
				child.expect('\(qemu\)')
				if "Migration status: completed" in child.before:
					break;

			time.sleep(3)
			print "migration completed"
			c.send(MSG_MIGRATE_COMPLETED)
			status = C_MIGRATION_COMPLETED

	if buf == MSG_TERMINATE:
		if monitor_child:
			vm_api.terminate_vms(monitor_child)
                else:
			vm_api.terminate_vms()
		c.send(MSG_TERMINATED)
		status = C_TERMINATED

def main():
	global status
	
        os.system("./setup-nfs-client.sh")
	clientsocket = connect_to_server()
	status = C_WAIT_FOR_BOOT_CMD

	while True:
		buf = clientsocket.recv(size)
		if not buf:
			print("Server is disconnected")
			sys.exit(0)
		else:
			handle_recv(clientsocket, buf)
			if status == C_TERMINATED:
				break;

if __name__ == '__main__':
	main()
