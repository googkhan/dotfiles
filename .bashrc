#PS1='[\u@\h \W]\$ '

# ssh agent alias added
alias ssha='eval $(ssh-agent) && ssh-add'

# Git branch in prompt.
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

EDITOR=vim

alias cp="cp -i"
alias df="df -h"
alias free="free -m"
alias more="less"
alias uu="apt update -y && apt dist-upgrade -y"
alias uc="yum update -y"
alias ua="pacman -Syu"
alias pacmansearch="pkgfile"
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alFrt --color'
alias la='ls -A'
alias l='ls -CF'
alias treeacl='tree -A -C -L 2'
alias cl='clear'
alias ..='cd ..'
alias ...='cd ..;cd ..'


#date
#curl wttr.in/?0
#
#if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#    tmux attach -t default || tmux new -s default
#fi

# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
} 
