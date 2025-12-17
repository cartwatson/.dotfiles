# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ---PROMPT---------------------------------------------------------------------

# get current branch
function __git_branch_ps1() {
    BRANCH=$(git branch --show-current --no-color 2> /dev/null)
    if [[ -n "$BRANCH" ]]; then
        printf " (%s)" "$BRANCH"
    fi
}
GIT_BRANCH=$(__git_branch_ps1)

# see if terminal is being remoted/ssh into
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_TYPE=remote/ssh
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) SESSION_TYPE=remote/ssh;;
    esac
fi

PROMPT_COMMAND='GIT_BRANCH=$(__git_branch_ps1);'

# create prompt line - example below
# user@machine(ssh session):working/dir/full/path (git branch)
# $
PS1='\[\033[01;32m\]\u@\h\[\033[0;36m\]${SESSION_TYPE:+("SSH")}\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$GIT_BRANCH\[\033[00m\]\033[01;32m\]${IN_NIX_SHELL:+ ($name)}${VIRTUAL_ENV:+ (venv)}\[\033[00m\]\n\$ '
# PS1='\u@\h${SESSION_TYPE:+("SSH")}:\w$GIT_BRANCH${IN_NIX_SHELL:+ ($name)}${VIRTUAL_ENV:+ (venv)}\n\$ ' # legacy, only used if color prompt not available

# ---COMPLETION+ALIASES---------------------------------------------------------

function __source_if_exists() {
    for file_path in "$@"; do
        [ -f "$file_path" ] && source $file_path
    done
}

# Alias definitions.
__source_if_exists "$HOME/.bash_aliases" "$HOME/.bash_aliases_machine.sh" "$HOME/.bashrc_machine.sh"

# enable programmable completion features
if ! shopt -oq posix; then
    __source_if_exists /usr/share/bash-completion/bash_completion /etc/bash_completion
fi

# case insensitive tab completion
bind -s 'set completion-ignore-case on'

# ---MISC-----------------------------------------------------------------------

# history file (`man bash` for more info)
HISTCONTROL=ignoreboth # ignore duplicate lines or lines starting with space
HISTSIZE=-1            # no limit
HISTFILESIZE=20000     # 20k lines

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support
if [ -x /usr/bin/dircolors ]; then
    [ -r $HOME/.dircolors ] && eval "$(dircolors -b $HOME/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# set default editor
export EDITOR="hx"
export VISUAL="$EDITOR"

# set terminal to be vim mode
set -o vi

# ---SERVICES-------------------------------------------------------------------

# start ssh-agent if not already started
if [ -n "$SSH_AGENT_PID" ]; then
    eval "$(ssh-agent -s)" > /dev/null;
    # add all private keys to ssh-agent
    find $HOME/.ssh -type f -regex '.*[a-zA-Z]+@[a-zA-Z]+[^.]*' | xargs ssh-add -q
fi

