#!/usr/bin/python

import vm_api
import time

vm_api.init(False)
vm_api.boot_vms()
child = vm_api.get_child()
child.interact()
