#!/usr/bin/env python
import os
import sys
import pexpect

def main():
	if not os.geteuid() == 0:
    		sys.exit('Script must be run as root')

	os.system("cp /proj/kvmarm-PG0/jintack/nested/vfio.img /vmdata/linaro-trusty.img")

	# Add host public key to guest
	os.system("mount -o loop /vmdata/linaro-trusty.img /mnt")
	os.system("cat /users/jintackl/.ssh/id_rsa.pub >> /mnt/root/.ssh/authorized_keys")
	os.system("mkdir -p /mnt_l2")
	os.system("mount -o loop /mnt/root/vm/l2.img /mnt_l2")
	os.system("cat /users/jintackl/.ssh/id_rsa.pub >> /mnt_l2/root/.ssh/authorized_keys")
	os.system("umount /mnt_l2")
	os.system("umount /mnt")

	os.system("cp nesting/run.sh /users/jintackl")
	os.system("cp nesting/trap_count.sh /users/jintackl")
	os.system("cp nesting/consume_mem.sh /users/jintackl")
	os.system("cp nesting/kvm_trace.sh /users/jintackl")
	os.system("cp nesting/copy-ssh-key.sh /users/jintackl")
	os.system("cp nesting/pin_vcpus_all.sh /users/jintackl")
	os.system("cp nesting/micro-cycles.py /users/jintackl")
	sys.exit(1)

if __name__ == '__main__':
	main()
