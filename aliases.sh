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
alias v="vim"
alias h="helix"

