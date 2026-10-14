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
alias ll="ls -AlvhG --group-directories-first --color=always --time-style=long-iso"
alias mkdir="mkdir -p"
alias sbr="source $HOME/.bashrc"

## tmux
alias  tp="$HOME/.dotfiles/nixos/modules/editors/tmux/sessions/personal.sh"
alias  tw="$HOME/.dotfiles/nixos/modules/editors/tmux/sessions/work.sh"
alias ide="$HOME/.dotfiles/nixos/modules/editors/tmux/sessions/windows/ide.sh"
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
alias glf="git log --oneline --patch --follow" # provide filename to scroll through history
alias gc="git commit -m"
alias gd="git diff --minimal"
alias gds="git diff --minimal --staged"
alias gp="git push"
alias gpl="git pull"
alias gsll="clear; ll; gs"
function gcom() { git checkout "$(git config init.defaultBranch)"; }
function gac() { git add "${@:1:$#-1}" && git commit -m "${@: -1}"; }
function gcp() { git commit -m "$@" && git push; }
function gacp() { git add "${@:1:$#-1}" && git commit -m "${@: -1}" && git push; }
function gpsu() { git push --set-upstream origin "$(git branch --show-current)"; }

## override builtins
# relies on above aliases: ll, gs
function cd() {
    builtin cd "$@"
    ll
    if [ -d ".git" ]; then gs; fi
}

alias clear="clear -x" # don't clear scroll

## misc
alias zip="tar -czf"
alias untar="tar -xvzf"
alias toggle-theme="$HOME/.dotfiles/toggle-gnome-helix-tmux-light_dark-mode.sh"
alias jfu="journalctl --output=short-iso --follow --unit"
# nonsense for jfu auto completetion
_jfu_complete() {
    local saved_words=("${COMP_WORDS[@]}")
    local saved_cword=$COMP_CWORD

    COMP_WORDS=(journalctl --unit "${COMP_WORDS[@]:1}")
    COMP_CWORD=$((saved_cword + 1))

    _journalctl

    COMP_WORDS=("${saved_words[@]}")
    COMP_CWORD=$saved_cword
}
complete -F _jfu_complete jfu

function git-init-custom-status() {
    local messages=(
        "Who built this?"
        "What files change often?"
        "What files are getting fixes?"
        "Commit count per month"
        "How often are reverts/hotfixes needed?"
    )
    local commands=(
        'git shortlog -sn --no-merges | head -5'
        'git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20'
        'git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20'
        'git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c'
        'git log --oneline --since="1 year ago" | grep -iE "revert|hotfix|emergency|rollback"'
    )

    for i in "${!messages[@]}"; do
        echo "${messages[i]}"
        eval "${commands[i]}"
        read -p "press enter..."
        echo
    done
}
