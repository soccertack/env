EXP_NO='$(uname -a | grep -o 'jintackl-qv[0-9]*' | grep -o '[0-9]*')'
PS1="\e[38;5;208m[\h $EXP_NO \w]\e[38;5;147m\[\$(__git_ps1)$\[\033[0m\]"
# More colors
# http://misc.flogisoft.com/bash/tip_colors_and_formatting

alias grep="grep --color --exclude=cscope*"
alias dgrep="dmesg | grep"
alias kg="pgrep qemu | xargs sudo kill -9"
alias gl="git log --oneline --decorate -n 10"
alias r="./run.sh"
