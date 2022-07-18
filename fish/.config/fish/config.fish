#!/usr/local/bin/fish
if status is-interactive
    set fish_greeting
end

# My prompt shell is starship
starship init fish | source
