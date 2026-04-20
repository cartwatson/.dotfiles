###############################################################################
#
# Bash Aliases
# common bash aliases to use on all machines
#
###############################################################################

## bash
alias cdm="clear; cd $HOME/personal"
alias cds="clear; cd $HOME/personal/idx"
alias cdw="clear; cd $HOME/work"
alias cdd="clear; cd $HOME/.dotfiles"
alias ll="ls -AlvhG --group-directories-first --color=always"
alias mkdir="mkdir -p"
alias sbr="source $HOME/.bashrc"

## tmux
alias tp="$HOME/.dotfiles/tmux/sessions/personal.sh"
alias tw="$HOME/.dotfiles/tmux/sessions/work.sh"
alias ide="$HOME/.dotfiles/tmux/sessions/windows/ide.sh"
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
alias gs="git status --short --branch"
alias ga="git add"
alias gl="git log --oneline --graph --decorate"
alias glf="git log --oneline --patch --follow"
alias gc="git commit -m"
alias gd="git diff --minimal"
alias gp="git push"
alias gpl="git pull"
alias gsll="clear; ll; gs"
function gco () {
    git checkout "$(git config init.defaultBranch)";
}
function gac() { git add "$1" && git commit -m "$2"; }
function gcp() { git commit -m "$@" && git push; }
function gacp() { git add "${@:1:$#-1}" && git commit -m "${@: -1}" && git push; }
function gpsu() { git push --set-upstream origin "$(git branch --show-current)"; }

## override builtins
function cd() {
    builtin cd "$@";
    ll;
    if [ -d ".git" ]; then
        gs;
    fi
}

alias clear="clear -x" # don't clear scroll

## misc
alias zip="tar -czf"
alias untar="tar -xvzf"
alias toggle-theme="$HOME/.dotfiles/toggle-gnome-helix-tmux-light_dark-mode.sh"
alias jfu="journalctl --output=short-iso --follow --unit"

alias rebuild="$HOME/.dotfiles/nixos/rebuild.sh"

function git-custom-init-status() {
    echo "Who built this?"
    git shortlog -sn --no-merges | head -5
    read

    echo "What files change often?"
    git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20
    read

    echo "What files are getting fixes?"
    git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20
    read

    echo "Commit count per month"
    git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c
    read

    echo "How often are reverts/hotfixes needed?"
    git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback'
    read
}
