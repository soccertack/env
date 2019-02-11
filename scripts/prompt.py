#!/usr/bin/python

import pexpect
import sys
import os
import datetime
import time
import socket

def wait_for_prompt(child, hostname):
    child.expect('%s.*#' % hostname)

hostname = os.popen('hostname | cut -d . -f1').read().strip()

child = pexpect.spawn('bash')
child.logfile = sys.stdout
child.timeout=None
wait_for_prompt(child, hostname)

child.sendline('ls')
wait_for_prompt(child, hostname)
