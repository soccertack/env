# <---- start of my bashrc

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [[ "`whoami`" == "root" ]]; then
	COLOR=178
	SHELL_CHAR="#"
else
	COLOR=208
	SHELL_CHAR="$"
fi
	
EXP_NO=`uname -a | awk '{print $2}' | cut -d. -f2`
PS1="\e[38;5;${COLOR}m[\h $EXP_NO \w]\e[38;5;147m\[\$(__git_ps1)\n${SHELL_CHAR}\[\033[0m\]"
# More colors
# http://misc.flogisoft.com/bash/tip_colors_and_formatting

source ~/.myalias

# This is to set the title of the terminal.
# e.g. $ title ML
function title {
    echo -ne "\033]0;"$*"\007"
}

# This is for wisc experiments
PATH=$PATH:/sdc/gcc/gcc-linaro/bin/:/sdc/gcc/gcc-linaro-arm32/bin/

set formatoptions=cro
export TERM=screen-256color

#  end of my bashrc ---->
