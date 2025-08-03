#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1="\[\e[0;36m\]\u@\h \[\e[0;33m\]\w\[\e[0m\] \[\e[90m\]⌛ \t\[\e[0m\]\n\$ "


