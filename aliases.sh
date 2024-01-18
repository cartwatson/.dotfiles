###############################################################################
#
# Bash Aliases
# common bash aliases to use on all machines
#
###############################################################################

# --bash
alias egs="echo -e '\n---- Git Status ----'"
alias ell="echo -e '---- List Files ----'"
alias cdh="clear; cd ~"
alias cdm="clear; cd ~/personal"
alias cds="clear; cd ~/personal/index"
alias cdw="clear; cd ~/work"
alias ll="ls -AlvhG"
alias vbr="vim ~/.bash_aliases"
alias sbr="source ~/.bashrc"
alias ebr="cat ~/.bash_aliases"

# --override builtins
function cd() { builtin cd "$@" && ll; }

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
alias gsll="clear; ell; ll; egs; gs"
function gcp() { git commit -m "$@" && git push; }
function gpsu() { git push --set-upstream origin $(git branch --show-current); }

