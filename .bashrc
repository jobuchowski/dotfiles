#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]$(basename $(dirname "$PWD"))/$(basename "$PWD")\[\033[1;31m\]\$\[\033[0m\] '

HISTCONTROL=erasedups

export EDITOR="nvim"
export VISUAL="nvim"

if [ -n "$DISPLAY" ]; then
  xset b off
fi

source ~/.bash_aliases

if [ -e ~/.bash_custom ]; then
    source ~/.bash_custom
fi

eval "$(zoxide init bash)"
