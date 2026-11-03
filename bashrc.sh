# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ---PROMPT---------------------------------------------------------------------

## --COLORS----------------------------
# \001/\002 are the raw bytes bash's \[ \] become; needed because PS1 variables
# are expanded after prompt-escape decoding, so a literal \[ would print as-is
GREEN=$'\001\033[01;32m\002'
BLUE=$'\001\033[01;34m\002'
RED=$'\001\033[01;31m\002'
CYAN=$'\001\033[0;36m\002'
YELLOW=$'\001\033[01;33m\002'
RESET=$'\001\033[00m\002'

## --HELPERS---------------------------
function __git_branch_ps1() {
    BRANCH=$(git branch --show-current --no-color 2> /dev/null)
    TAG=$(git describe --exact-match --tags 2> /dev/null)

    [[ -n "$BRANCH" ]] && printf " %s(%s)" "$RED" "$BRANCH"
    [[ -n "$TAG"    ]] && printf " %s(%s)" "$YELLOW" "$TAG"
}
# append git check and guard against adding multiple git checks on re-source
if [[ "$PROMPT_COMMAND" != *__git_branch_ps1* ]]; then
    PROMPT_COMMAND='GIT_BRANCH=$(__git_branch_ps1)'${PROMPT_COMMAND:+";$PROMPT_COMMAND"}
fi

# see if terminal is being remoted into
[[ -n "$SSH_CLIENT$SSH_TTY" ]] && SESSION_TYPE=remote/ssh

## --PROMPT-CREATION-------------------
# create prompt line
PS1='${CYAN}${SESSION_TYPE:+(SSH) }'                                           # SSH session indicator
PS1+='${GREEN}\u@\h${RESET}:'                                                  # user + host
PS1+='${BLUE}\w'                                                               # working dir (from user home)
PS1+='${GIT_BRANCH}'                                                           # git branch and/or tag
PS1+='${GREEN}${IN_NIX_SHELL:+ ($name)}${VIRTUAL_ENV:+ (venv)}'                # Nix Shell indicator
PS1+='${RESET}\n\$ '                                                           # input on newline

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
bind 'set completion-ignore-case on'

# ctrl+R fzf
eval "$(fzf --bash)"

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

