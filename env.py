#!/usr/bin/env python
import os
import sys
import argparse
import os.path

HOME="~"
USER=""

def setup_home_dir(user):
	global HOME

	if user == "root":
		HOME = "/root"
	else:
		HOME = "/users/"+user

def make_dir(directory):
	if not os.path.exists(directory):
	    os.makedirs(directory)

def gen_sshkey(force):
	priv_file="%s/.ssh/id_rsa" % HOME
	pub_file=priv_file+".pub"

	if force:
		# Delete key files and start over!
		os.system("rm %s" % priv_file)
		os.system("rm %s" % pub_file)
	else:
		if os.path.isfile(pub_file) or os.path.isfile(priv_file):
			print ("%s or %s already exists\n" % (pub_file, priv_file))
			return

	cmd = "ssh-keygen -f %s -t rsa -b 4096 -C \"jintack@cs.columbia.edu\" -N ''" % priv_file
	os.system(cmd)

	os.system("cat %s" % pub_file)

	# If we generated keys with root, change permissions to the specified user
	if USER != "":
		os.system("chown %s:kvmarm-PG0 %s %s" % (USER, priv_file, pub_file))

def install_omz():
	zsh_dir = HOME+"/.oh-my-zsh"
	if os.path.exists(zsh_dir):
		return

	cmd = "sh -c \"$(wget https://raw.githubusercontent.com/soccertack/oh-my-zsh/master/tools/install.sh -O -)\""
	os.system(cmd)

def install_tig():
	os.system("wget https://github.com/jonas/tig/releases/download/tig-2.3.3/tig-2.3.3.tar.gz ")
	os.system("tar xvfz tig-2.3.3.tar.gz")

	cmd = ""
	cmd += "cd tig-2.3.3"
	cmd += "&&" + "make prefix=/usr/local"
	cmd += "&&" + "sudo make install prefix=/usr/local"
	cmd += "&&" + "cd .."
	os.system(cmd)

def setup_packages():
	os.system("sudo apt-get update")
	os.system("sudo apt-get -y install vim exuberant-ctags git cscope pastebinit python-pexpect screen expect libncurses5-dev libncursesw5-dev u-boot-tools device-tree-compiler tig htop sysstat flex tmux sysfsutils pbzip2 libelf-dev sipcalc python-numpy tree ")



def setup_vim():
	VIMRC_SRC="vimrc"
	VIMRC_DEST=HOME+"/.vimrc"

	cmd = 'cp %s %s' % (VIMRC_SRC, VIMRC_DEST)
	os.system(cmd)

	if USER != "":
		os.system("chown %s:kvmarm-PG0 %s" % (USER, VIMRC_DEST))

def setup_bash():
	BASHRC_SRC="bashrc"
	BASHRC_DEST=HOME+"/.bashrc"
	MY_BASHRC=HOME+"/.mybashrc"

	cmd = 'cp %s %s' % (BASHRC_SRC, MY_BASHRC)
	os.system(cmd)

	cmd = 'source ' + MY_BASHRC
	cmd = "echo '%s' >> %s" % (cmd, BASHRC_DEST)
	os.system(cmd)

	if USER != "":
		os.system("chown %s:kvmarm-PG0 %s" % (USER, MY_BASHRC))

def setup_tig():
	install_tig()
	TIGRC_SRC="tigrc"
	TIGRC_DEST=HOME+"/.tigrc"

	cmd = 'cp %s %s' % (TIGRC_SRC, TIGRC_DEST)
	os.system(cmd)

	if USER != "":
		os.system("chown %s:kvmarm-PG0 %s" % (USER, TIGRC_DEST))

def setup_git():
	gitconfig_src = "gitconfig"
	gitconfig_dest = HOME+"/.gitconfig"

	cmd = 'cp %s %s' % (gitconfig_src, gitconfig_dest)
	os.system(cmd)

	if USER != "":
		os.system("chown %s:kvmarm-PG0 %s" % (USER, gitconfig_dest))

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

	force = False 

	parser = argparse.ArgumentParser()
	parser.add_argument("-u", "--user", help="setup user")
	parser.add_argument("-m", "--mru", help="install mru", action='store_true')
	parser.add_argument("-v", "--vim", help="setup vim", action='store_true')
	parser.add_argument("-b", "--bash", help="setup bash", action='store_true')
	parser.add_argument("-g", "--git", help="setup git", action='store_true')
	parser.add_argument("-p", "--package", help="install packages", action='store_true')
	parser.add_argument("-k", "--sshkey", help="generate ssh key", action='store_true')
	parser.add_argument("-a", "--all", help="setup all", action='store_true')
	parser.add_argument("-f", "--force", help="force to create a new ssh key", action='store_true')
	args = parser.parse_args()

	# Set LANG
	os.system("sudo update-locale LANG=en_US.UTF-8")
	
	if args.user:
		global USER 
		USER = args.user
		setup_home_dir(args.user)

	if args.force:
		force = True 
	
	if args.all:
		setup_packages()
		setup_vim()
		install_mru()
		install_cscope()
		setup_bash()
		setup_git()
		setup_scp()
		setup_tig()
		gen_sshkey(force)
		install_omz():
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
		gen_sshkey(force)

	sys.exit(0)

if __name__ == '__main__':
	main()
