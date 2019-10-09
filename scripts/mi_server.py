#!/usr/bin/python

import select
import pexpect
import sys
import os
import datetime
import time
import socket
from sk_common import *
from mi_common import *
import vm_api
import common

level = 0
vm_addr = ['10.10.1.1', '10.10.1.100', '10.10.1.101', '10.10.1.102']
#Connection status fields
IDX_STATUS = 0
IDX_IP_ADDR = 1

#Server-Client status
SC_CONNECTED = 1
SC_WAIT_FOR_BOOT = 2
SC_NVM_READY = 3
SC_NVM_TERMINATED = 4

#Server status
S_WAIT_FOR_CONNECTION = 0
S_WAIT_FOR_BOOT = 1
S_NVM_READY = 2
S_MIGRAION_START = 3
S_MIGRAION_END = 4
S_WFT = 5 # Wait for termination
S_MIGRAION_CHECK = 6

workloads = {
            'netperf-rr' : 'MIGRATED TCP',
            'netperf-stream' : 'MIGRATED TCP',
            'netperf-maerts' : 'MIGRATED TCP',
            'memcached' : 'Connections per thread',
            'apache' : 'Server Software',
            'mysql': 'Threads started!',
            'hackbench': 'Running with'
            }

def set_status(conn, st):
	conn_status[conn][IDX_STATUS] = st

def is_status(conn, st):
	if conn_status[conn][IDX_STATUS] == st:
		return True 
	return False

def get_ip(conn):
	return conn_status[conn][IDX_IP_ADDR]

def get_src_conn():

	for conn in clients:
		if get_ip(conn)  == "10.10.1.2":
			return conn
	return

def get_dst_conn():

	for conn in clients:
		if get_ip(conn)  == "10.10.1.3":
			return conn
	return

def check_all_conn(conn_status):
	src_ready = False
	dest_ready = False
	# Check if all connections are ready
	for conn in clients:
		if is_status(conn, conn_status):
			if get_ip(conn)  == "10.10.1.2":
				src_ready = True
			if get_ip(conn)  == "10.10.1.3":
				dest_ready = True

	return src_ready and dest_ready

def terminate_all():
	for conn in clients:
		conn.send(MSG_TERMINATE)

def ping():
	while True:
		if (os.system("ping -c 1 " + vm_addr[level]) == 0):
			break;
		print ("ping was not successfull. Retry after one sec")
		time.sleep(1)

def init():
    global conn_status
    global outputs
    global clients
    global inputs
    global s
    global server_status

    conn_status = {}
    outputs = []
    clients = []
    inputs = []
    inputs.append(s)
    server_status = S_WAIT_FOR_CONNECTION

def handle_recv(conn, data):
	global server_status
        global inputs
        global clients
        
        if data:
	    print (data + " is received")

	# Per connection status
	if is_status(conn, SC_WAIT_FOR_BOOT):
		if data == MSG_BOOT_COMPLETED:
			set_status(conn, SC_NVM_READY)

	if (server_status == S_WAIT_FOR_CONNECTION) and check_all_conn(SC_CONNECTED):
	    for conn in clients:
	        boot_nvm(conn)
            server_status = S_WAIT_FOR_BOOT

	# Server state
	if (server_status == S_WAIT_FOR_BOOT) and check_all_conn(SC_NVM_READY):
		time.sleep(3)
		ping()
		print ("Ping was successful.")
		
                if interactive:
                    service = raw_input("Enter any service you want to start in the nVM: ") 
                    if service != "":
                        os.system("ssh root@%s service %s start" % (vm_addr[level], service))

                    raw_input("Enter when you are ready to do migration") 
                elif autoMeasurement:
                    src_conn = get_src_conn()
                    src_conn.send(curr_workload[0])
                    mc.sendline('./run_all.sh L%s %s' % (str(level), curr_workload[0]))
                    mc.expect(curr_workload[1])
                    if curr_workload[0] in ['mysql', 'hackbench']:
                        time.sleep(10)

		src_conn = get_src_conn()
		src_conn.send(MSG_MIGRATE)
		print("start migration")
		server_status = S_MIGRAION_START

	if server_status == S_MIGRAION_START:
		# Migration on the source is complete. Check on the destination
		if data == MSG_MIGRATE_COMPLETED:
			server_status = S_MIGRAION_CHECK
			dst_conn = get_dst_conn()
			dst_conn.send(MSG_MIGRATE_CHECK)

	if server_status == S_MIGRAION_CHECK:
		if data == MSG_MIGRATE_CHECKED:
			time.sleep(2)
			ping()
			print ("Ping was successful after migration")

			print("migration is completed")
                        if interactive:
		            raw_input("Enter when you are ready to terminate VMs") 
                        elif autoMeasurement:
                            mc.send(chr(3))
                            vm_api.wait_for_prompt(mc, hostname)
			print("send messages to terminate VMs")
			terminate_all()
			server_status = S_WFT

        if server_status== S_WFT:
                if data == MSG_TERMINATED:

			del conn_status[conn]
			inputs.remove(conn)
			clients.remove(conn)
			conn.close()
                        print ("terminated", conn)
                        if not len(clients):
                            print ("all terminated")
                            server_status = S_MIGRAION_END
			

def boot_nvm(conn):
	conn.send(MSG_BOOT)
	conn_status[conn][IDX_STATUS] = SC_WAIT_FOR_BOOT

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

print ("Try to bind...")
while True:
	try:
		s.bind(('', PORT))
		break;
	except socket.error:
		print ("Bind error. Try again")
		time.sleep(1)
print ("Done.")

print ("Try to listen...")
s.listen(2) # become a server socket.
print ("Done.")

level = int(raw_input("Enter the top virtualization level(default: 2): ") or '2')

while True:
    string = "Running options: [I]nteractive(default), [M]easure, or [R]epeat: "

    option = raw_input(string)

    interactive = False
    autoMeasurement = False
    if option == 'R' or option == 'r':
        break
    if option == 'I' or option == 'i' or option == '':
        interactive = True
        break
    if option == 'M' or option == 'm':
        autoMeasurement = True
        break
    print ('Invalid input')

if autoMeasurement:
    hostname = common.get_hostname()

    #mc: measurement child
    mc = pexpect.spawn('bash')
    mc.logfile_read=sys.stdout
    mc.timeout=None
    vm_api.wait_for_prompt(mc, hostname)

    mc.sendline('cd kvmperf/cmdline_tests')
    vm_api.wait_for_prompt(mc, hostname)

init()

iter_cnt = 0
m_cnt = 0
wi = workloads.iteritems()
curr_workload = wi.next()

while inputs:
	readable, writable, exceptional = select.select(inputs, outputs, inputs)

	for item in readable:
		if item == s:
			#handle connection
			conn, addr = s.accept()
			if "10.10.1" not in addr[0]:
				s.close()
				print 'Suspcious connection from %s. Disconnect' % addr[0]
			else:
				print 'Connected with ' + addr[0] + ':' + str(addr[1])
				inputs.append(conn)
				clients.append(conn)
				conn_status[conn] = [SC_CONNECTED, addr[0]]
				handle_recv(conn, None)

		else:
			data = item.recv(size)
			if data:
				handle_recv(item, data)
				if server_status == S_MIGRAION_END:
                                    iter_cnt += 1
                                    print ("%dth iterations" % iter_cnt)
                                    m_cnt += 1
                                    if m_cnt == 2:
                                        m_cnt = 0
                                        try:
                                            curr_workload = wi.next()
                                        except StopIteration:
                                            sys.exit(0)
                                    init()
			else:
				print(conn_status[item][IDX_IP_ADDR])
				print ('Connection closed')
				del conn_status[item]
				inputs.remove(item)
				clients.remove(item)
				item.close()
