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

hostname = os.popen('hostname | cut -d . -f1').read().strip()

child = pexpect.spawn('bash')
child.logfile_read=sys.stdout
child.timeout=None

child.sendline('sudo chsh')
child.expect('Login Shell.*:')

child.sendline('/usr/bin/zsh')
child.expect('%s.*' % hostname)
