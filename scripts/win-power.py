#!/usr/bin/python
import pexpect

child = pexpect.spawn('bash')
child.timeout=None

child.sendline('ssh Administrator@10.10.1.100')
child.expect('password:')
child.sendline('a1s2D#gg')
child.expect('Administrator>')
child.sendline('PowerShell')
child.interact()
