#!/usr/local/bin/fish
if status is-interactive
    set fish_greeting
end

# Some aliases
alias vim='nvim'

# My prompt shell is starship
starship init fish | source

# My personal environment variables
fish ~/.env.fish
