#!/usr/bin/python
import os
import sys

KVM_TRACE_PATH="/sys/kernel/debug/tracing/events/kvm"
cmd=["Quit", "KVM All"]

def show_traces():
	i = 1
	print "----------------------------------"
	prev_item = '{:02}'.format(1)+".[-] "+cmd[i]
	i +=1
	for dirname in os.walk(KVM_TRACE_PATH).next()[1]:
		f = open(KVM_TRACE_PATH+"/"+dirname+"/enable", "r")
		trace_on = f.read()
		f.close()
		trace_on = trace_on.rstrip('\r\n')
		cmd.append(dirname)
		item = '{:02}'.format(i)+".["+trace_on+"] "+dirname

		# Print two columns
		if i%2 == 0:
			print '{0:40}  {1}'.format(prev_item, item)
		else:
			prev_item = item

		i += 1
	print "----------------------------------"

while 1:
	show_traces()
	trace_num = input("Enter trace number: [0 to quit] ")
	if trace_num == 0:
		sys.exit(1)
	val = input("Set " + cmd[trace_num] + " to 0 or 1? ")
	if trace_num == 1:
		os.system("echo "+str(val)+" > " + KVM_TRACE_PATH+"/enable")
	else:
		os.system("echo "+str(val)+" > " + KVM_TRACE_PATH+"/"+cmd[trace_num]+"/enable")

