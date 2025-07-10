###############################################################################
#
# Bash Aliases
# common bash aliases to use on all machines
#
###############################################################################

## bash
alias cdm="clear; cd ~/personal"
alias cds="clear; cd ~/personal/index"
alias cdw="clear; cd ~/work"
alias cdd="clear; cd ~/.dotfiles"
alias ll="ls -AlvhG --group-directories-first"
alias mkdir="mkdir -p"
alias sbr="source ~/.bashrc"

## tmux
alias tp="~/.dotfiles/tmux/sessions/personal.sh"
alias tw="~/.dotfiles/tmux/sessions/work.sh"
alias ide="~/.dotfiles/tmux/sessions/windows/ide.sh"
alias tls="tmux list-sessions"
function tks() {
    if [ -n "$1" ]; then
        # provided name
        tmux kill-session -t "$1"
        return "$?"
    fi

    if [ -n "$TMUX" ]; then
        session_to_kill=$(tmux display-message -p '#S')
        tmux switch-client -l
        tmux kill-session -t "$session_to_kill"
    else
        # not in tmux
        return 1
    fi
}
function tas() {
    if [ -z "$TMUX" ]; then
        tmux attach-session -t "$1";
    fi
    tmux switch -t "$1";
}

## git
alias gs="git status -sb"
alias ga="git add"
alias gl="git log --oneline --graph --decorate"
alias gc="git commit -m"
alias gd="git diff --minimal"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gsll="clear; ll; gs"
function gac() { git add "$1" && git commit -m "$2"; }
function gcp() { git commit -m "$@" && git push; }
function gacp() { git add "$1" && git commit -m "$2" && git push; }
function gpsu() { git push --set-upstream origin $(git branch --show-current); }

## override builtins
function cd() {
    builtin cd "$@";
    ll;
    if [ -d ".git" ]; then
        git status -sb;
    fi
}

alias clear="clear -x" # don't clear scroll

## misc
alias untar="tar -xvzf"
alias update-theme="$HOME/.dotfiles/set-dark-light-mode.sh"

