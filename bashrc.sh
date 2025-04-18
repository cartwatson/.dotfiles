# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# always assume color prompt
color_prompt=yes

# attempt to source git-prompt.sh if it exists
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    # Obtain from https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
    source /usr/share/git-core/contrib/completion/git-prompt.sh
else
    # define function to emulate git-prompt.sh
    # credit: unknown, seems to have been pasted everywhere
    function __git_ps1() {
        local branch
        branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
        if [ "$branch" != "" ]; then
            printf "%s" "$branch"
        fi
    }
fi

# see if terminal is being remoted/ssh into
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    session_type=remote/ssh
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) session_type=remote/ssh;;
    esac
fi

# create prompt line - example below
# user@machine(ssh session):working/dir/full/path (git branch)
# $
if [[ "$color_prompt" = yes ]]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[0;36m\]${session_type:+("SSH")}\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(__git_ps1)\[\033[00m\]\033[01;32m\]${IN_NIX_SHELL:+ ($name)}${VIRTUAL_ENV:+ (venv)}\[\033[00m\]\n\$ '
else
    PS1='\u@\h${session_type:+("SSH")}:\w$(__git_ps1)${IN_NIX_SHELL:+ ($name)}${VIRTUAL_ENV:+ (venv)}\n\$ '
fi
unset color_prompt
unset session_type

# If this is an xterm set the title of the window to user@host:dir # NOTE: definitely not necessary
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

function source_if_exists() {
    for file_path in "$@"; do
        [ -f "$file_path" ] && source $file_path
    done
}

# Alias definitions.
source_if_exists "$HOME/.bash_aliases" "$HOME/.bash_aliases_machine.sh" "$HOME/.bashrc_machine.sh"

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi

# case insensitive tab completion
bind -s 'set completion-ignore-case on'

# set default editor
export EDITOR="hx"
export VISUAL="$EDITOR"

# set terminal to be vim mode
set -o vi

# start ssh-agent if not already started
if [ -n "$SSH_AGENT_PID" ]; then
    eval "$(ssh-agent -s)" > /dev/null;
    # add all private keys to ssh-agent
    find ~/.ssh -type f -regex '.*[a-zA-Z]+@[a-zA-Z]+[^.]*' | xargs ssh-add -q
fi

