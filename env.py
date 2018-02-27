#!/usr/bin/env python
import os
import sys
import argparse

HOME="~"

def setup_directories_root():
	global HOME
	HOME = "/root"

def make_dir(directory):
	if not os.path.exists(directory):
	    os.makedirs(directory)

def gen_sshkey():
	output_file="%s/.ssh/id_rsa" % HOME
	cmd = "ssh-keygen -f %s -t rsa -b 4096 -C \"jintack@cs.columbia.edu\" -N ''" % output_file
	os.system(cmd)
	os.system("cat %s/.ssh/id_rsa.pub" % HOME)

def setup_packages():
	os.system("sudo apt-get update")
	os.system("sudo apt-get -y install vim exuberant-ctags git cscope pastebinit python-pexpect screen expect libncurses5-dev libncursesw5-dev u-boot-tools device-tree-compiler tig htop sysstat flex tmux sysfsutils pbzip2 libelf-dev sipcalc")

def setup_vim():
	VIMRC_SRC="vimrc"
	VIMRC_DEST=HOME+"/.vimrc"

	cmd = 'cp %s %s' % (VIMRC_SRC, VIMRC_DEST)
	os.system(cmd)

def setup_bash():
	BASHRC_SRC="bashrc"
	BASHRC_DEST=HOME+"/.bashrc"
	MY_BASHRC=HOME+"/.mybashrc"

	cmd = 'cp %s %s' % (BASHRC_SRC, MY_BASHRC)
	os.system(cmd)

	cmd = 'source ' + MY_BASHRC
	cmd = "echo '%s'" % cmd
	os.system(cmd)

def setup_tig():
	TIGRC_SRC="tigrc"
	TIGRC_DEST=HOME+"/.tigrc"

	cmd = 'cp %s %s' % (TIGRC_SRC, TIGRC_DEST)

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
	os.system("git config --global alias.f 'commit --fixup'")
	os.system("git config --global alias.no 'notes add'")
	os.system("git config --global rerere.enabled true")
	os.system("git config --global alias.cp cherry-pick")
	os.system("git config --global alias.cpc 'cherry-pick --continue'")

def install_cscope():
	os.system("wget http://cs.columbia.edu/~jintack/cscope_maps.vim -P %s/.vim/plugin" % HOME)

def install_mru():
	os.system("git clone https://github.com/soccertack/mru.git mru")

	vim_config_dir = os.path.join(os.path.expanduser(HOME), ".vim")
	make_dir(vim_config_dir)

	plugin_dir = os.path.join(os.path.expanduser(HOME), ".vim/plugin")
	make_dir(plugin_dir)

	os.system("cp mru/plugin/mru.vim %s/.vim/plugin/mru.vim" % HOME)
	os.system("rm -rf mru")

def setup_scp():
	os.system("sudo cp scpto /usr/local/bin")

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("-u", "--user", help="setup user")
	parser.add_argument("-m", "--mru", help="install mru", action='store_true')
	parser.add_argument("-v", "--vim", help="setup vim", action='store_true')
	parser.add_argument("-b", "--bash", help="setup bash", action='store_true')
	parser.add_argument("-g", "--git", help="setup git", action='store_true')
	parser.add_argument("-p", "--package", help="install packages", action='store_true')
	parser.add_argument("-k", "--sshkey", help="generate ssh key", action='store_true')
	parser.add_argument("-a", "--all", help="setup all", action='store_true')
	args = parser.parse_args()

	# Set LANG
	os.system("sudo update-locale LANG=en_US.UTF-8")
	
	if args.user and args.user =="root":
		setup_directories_root()
	
	if args.all:
		setup_packages()
		setup_vim()
		install_mru()
		install_cscope()
		setup_bash()
		setup_git()
		setup_scp()
		gen_sshkey()
		sys.exit(0)
	if args.mru:
		install_mru()
	if args.vim:
		setup_vim()
	if args.git:
		setup_git()
	if args.bash:
		setup_bash()
	if args.package:
		setup_packages()
	if args.sshkey:
		gen_sshkey()

	sys.exit(0)

if __name__ == '__main__':
	main()
