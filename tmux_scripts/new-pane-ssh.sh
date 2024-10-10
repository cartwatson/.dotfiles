#!/usr/bin/env bash
# Author: github.com/cartwatson
# Desc: copy ssh session to new panes in tmux

##### TODO
# determine if ssh
# if ssh
#   ssh into session
# copy dir and cd to it

# see if terminal is being remoted/ssh into
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_TYPE=remote/ssh
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) SESSION_TYPE=remote/ssh;;
    esac
fi

echo "$SESSION_TYPE"

# if [ -n SESSION_TYPE ]; then

# else

# fi
