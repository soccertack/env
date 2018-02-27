# <---- start of my bashrc

EXP_NO=`uname -a | awk '{print $2}' | cut -d. -f2`
PS1="\e[38;5;178m[\h $EXP_NO \w]\e[38;5;147m\[\$(__git_ps1)\n$\[\033[0m\]"
# More colors
# http://misc.flogisoft.com/bash/tip_colors_and_formatting

alias grep="grep --color --exclude=cscope*"
alias dgrep="dmesg | grep"
alias kg="pgrep qemu | xargs sudo kill -9"
alias gl="git log --oneline --decorate -n 30"
alias gs="git status"
alias grc="git rebase --continue"
alias ifc="ifconfig | grep inet"
alias mk="./make.sh"
alias r="pushd ~;./run.sh;popd"
alias v="cd /srv/vm;sudo su"

# This is to set the title of the terminal.
# e.g. $ title ML
function title {
    echo -ne "\033]0;"$*"\007"
}

# This is for wisc experiments
PATH=$PATH:/mydata/gcc-linaro/bin/:/mydata/gcc-linaro-arm32/bin/

set formatoptions=cro
export TERM=screen-256color

#  end of my bashrc ---->
