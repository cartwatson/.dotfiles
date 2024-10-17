###############################################################################
#
# Bash Aliases
# common bash aliases to use on all machines
#
###############################################################################

# --bash
alias cdh="clear; cd ~"
alias cdm="clear; cd ~/personal"
alias cds="clear; cd ~/personal/index"
alias cdw="clear; cd ~/work"
alias cdd="clear; cd ~/.dotfiles"
alias ll="ls -AlvhG"
alias mkdir="mkdir -p"
alias sbr="source ~/.bashrc"

# --tmux
alias tp="~/.dotfiles/tmux_scripts/personal.sh"
alias tw="~/.dotfiles/tmux_scripts/work.sh"
alias tls="tmux list-sessions"
function tks() {
    if [ -n "$1" ]; then
        # provided name
        tmux kill-session -t "$1"
        return "$?"
    fi

    if [ -n "$TMUX" ]; then
        current_session=$(tmux display-message -p '#S')
        tmux kill-session -t "$current_session"
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

# --git
alias gs="git status -sb"
alias ga="git add"
alias gl="git log --oneline --graph --decorate"
alias gc="git commit -m"
alias gd="git diff"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gcod="git checkout dev"
alias gsll="clear; ll; gs"
function gac() { git add "$1" && git commit -m "$2"; }
function gcp() { git commit -m "$@" && git push; }
function gacp() { git add "$1" && git commit -m "$2" && git push; }
function gpsu() { git push --set-upstream origin $(git branch --show-current); }

# --override builtins
function cd() {
    builtin cd "$@";
    ll;
    if [ -d ".git" ]; then
        git status -sb;
    fi
}

# --misc
alias unzip="tar -xvzf"

