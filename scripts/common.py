import os

def get_hostname():
    return os.popen('hostname | cut -d . -f1').read().strip()
