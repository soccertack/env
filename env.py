#!/usr/bin/env python
import os
import sys
import argparse

VIMRC_SRC="vimrc"
VIMRC_DEST="~/.vimrc"
BASHRC_SRC="bashrc"
BASHRC_DEST="~/.bashrc"

def make_dir(directory):
	if not os.path.exists(directory):
	    os.makedirs(directory)

def gen_sshkey():
	os.system("ssh-keygen -f \"${HOME}/.ssh/id_rsa\"  -t rsa -b 4096 -C \"jintack@cs.columbia.edu\" -N ''")
	os.system("cat ~/.ssh/id_rsa.pub")

def setup_packages():
	os.system("sudo apt-get update")
	os.system("sudo apt-get -y install vim exuberant-ctags git cscope pastebinit python-pexpect screen expect libncurses5-dev libncursesw5-dev u-boot-tools device-tree-compiler")

def setup_vim():
	os.system("cat "+VIMRC_SRC+" >> "+VIMRC_DEST)

def setup_bash():
	os.system("cat "+BASHRC_SRC+" >> "+BASHRC_DEST)

def setup_git():
	os.system("git config --global user.email jintack@cs.columbia.edu")
	os.system("git config --global user.name 'Jintack Lim'")
	os.system("git config --global core.editor vim")
	os.system("git config --global push.default simple")
	os.system("git config --global rebase.autosquash true")
	os.system("git config --global notes.rewrite.rebase true")
	os.system("git config --global notes.rewrite.amend true")
	os.system("git config --global notes.rewriteRef refs/notes/commits")
	os.system("git config --global core.pager 'less -+F'")

def install_cscope():
	os.system("wget http://cscope.sourceforge.net/cscope_maps.vim -P ~/.vim/plugin")

def install_mru():
	os.system("git clone https://github.com/soccertack/mru.git mru")

	vim_config_dir = os.path.join(os.path.expanduser("~"), ".vim")
	make_dir(vim_config_dir)

	plugin_dir = os.path.join(os.path.expanduser("~"), ".vim/plugin")
	make_dir(plugin_dir)

	os.system("cp mru/plugin/mru.vim ~/.vim/plugin/mru.vim")
	os.system("rm -rf mru")

def setup_scp():
	os.system("sudo cp scpto /usr/local/bin")

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("-m", "--mru", help="install mru", action='store_true')
	parser.add_argument("-v", "--vim", help="setup vim", action='store_true')
	parser.add_argument("-b", "--bash", help="setup bash", action='store_true')
	parser.add_argument("-g", "--git", help="setup git", action='store_true')
	parser.add_argument("-a", "--all", help="setup all", action='store_true')
	args = parser.parse_args()

	setup_packages()
	if args.all:
		setup_vim()
		install_mru()
		install_cscope()
		setup_bash()
		setup_git()
		setup_scp()
		gen_sshkey()
		sys.exit(1)
	if args.mru:
		install_mru()
	if args.vim:
		setup_vim()
	if args.git:
		setup_git()
	if args.bash:
		setup_bash()

	sys.exit(1)

if __name__ == '__main__':
	main()
