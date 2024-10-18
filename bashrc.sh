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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# always assume color prompt
color_prompt=yes
force_color_prompt=yes

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
            printf " %s" $branch
        fi
    }
fi

# see if terminal is being remoted/ssh into
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_TYPE=remote/ssh
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) SESSION_TYPE=remote/ssh;;
    esac
fi

# create prompt line - example below
# user@machine(ssh session):working/dir/full/path (git branch)
# $
if [[ "$color_prompt" = yes ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[0;36m\]${SESSION_TYPE:+("SSH")}\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(__git_ps1)\[\033[00m\]\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h${SESSION_TYPE:+("SSH")}:\w$(__git_ps1)\n\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
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

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# machine bashrc functions
if [ -f ~/.bash_machine_rc.sh ]; then
    source ~/.bash_machine_rc.sh
fi

# machine specific aliases
if [ -f ~/.bash_machine_aliases.sh ]; then
    source ~/.bash_machine_aliases.sh
fi

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
export EDITOR='hx'
export VISUAL='$EDITOR'

# set terminal to be vim mode
set -o vi

# start ssh-agent if not already started
if [ -n $SSH_AGENT_PID ]; then
    eval "$(ssh-agent -s)" > /dev/null;
    # add all private keys to ssh-agent
    find ~/.ssh -type f -regex '.*[a-zA-Z]+@[a-zA-Z]+[^.]*' | xargs ssh-add -q
fi

# home for one off commands
if [ -f "$HOME/.cargo/env" ]; then source "$HOME/.cargo/env"; fi

