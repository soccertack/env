#!/usr/bin/python

import vm_api
import time

vm_api.init()
vm_api.boot_vms()
print("Hi we are here")
time.sleep(5)
vm_api.halt(2)
