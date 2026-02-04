#!/usr/bin/env bash
# Author: github.com/cartwatson
# Desc: Init new systems with config files

# Working Dir
WORKING_DIR=$(pwd)

# Define ANSI escape codes
red_bg="\033[41m"     # Red background
blue_bg="\033[44m"    # Blue background
green_bg="\033[42m"   # Green background
reset="\033[0m"       # Reset formatting

# fun functions for creating distinct visuals
function print_error() { echo -e "${red_bg}ERROR: $1${reset}"; }
function print_pending() { echo -e "${blue_bg}Pending: $1${reset}"; }
function print_success() { echo -e "${green_bg}Completed: $1${reset}"; }
function print_info() { echo -e "${blue_bg}Info: $1${reset}"; }

function backup_files() {
    for file in "$@"; do
        if [ ! -L "$file" ]; then # if not symlink
            mv "$file" "$file.old"
        fi
    done
}

function create_dir() {
    if [ ! -d "$HOME/$1" ]; then
        print_pending "Creating $1..."
        if mkdir -p "$HOME/$1"; then
            print_success "Created $1"
        else
            print_error "Creating $1"
        fi
    fi
}

# installation functions
function symlink_config {
    # create backups
    backup_files "$HOME/.bashrc" "$HOME/.gitconfig"

    # create symlinks for files
    failed=0
    print_pending "Creating symlinks for bashrc, aliases, vimconfig, gitconfig, and tmuxconfig..."
    ln -s "$WORKING_DIR"/bashrc.sh          "$HOME"/.bashrc          || ((failed++))
    ln -s "$WORKING_DIR"/aliases.sh         "$HOME"/.bash_aliases    || ((failed++))
    ln -s "$WORKING_DIR"/profile.sh         "$HOME"/.profile         || ((failed++))
    ln -s "$WORKING_DIR"/vimrc.vim          "$HOME"/.vimrc           || ((failed++))
    ln -s "$WORKING_DIR"/gitconfig-personal "$HOME"/.gitconfig       || ((failed++))
    ln -s "$WORKING_DIR"/tmux/tmux.conf     "$HOME"/.tmux.conf       || ((failed++))

    if [ ! -f ~/work/.gitconfig ]; then
        # don't create symlink here so this file can be edited
        ln "$WORKING_DIR"/gitconfig-personal "$HOME"/work/.gitconfig
    fi

    if [ "$failed" -eq 0 ]; then
        print_success "Created symlinks!"
    else
        print_error "Failed to link $failed aspects of bash config"
    fi
}

function dotfiles_repo_https_to_ssh {
    # convert this repo to ssh if https
    if git remote get-url origin | grep -qc https; then
        print_pending "Converting from https to ssh..."
        git remote set-url origin git@github.com:cartwatson/.dotfiles.git

        if [ "$?" -eq 0 ]; then
            print_success "Converted \`~/.dotfiles\` from https to ssh"
        else
            print_error "Converting \`~/.dotfiles\` from https to ssh"
        fi
    fi
}

function reinstall_helix_config {
    print_pending "Installing helix config..."
    create_dir "$HOME/.config"
    rm -rf "$HOME/.config/helix"
    ln -s "$HOME/.dotfiles/helix" "$HOME/.config/helix"

    if ln -s "$HOME/.dotfiles/helix" "$HOME/.config/helix"; then
        print_success "Installed helix config"
    else
        print_error "Failed to link helix config files"
    fi
}

function add_alias_if_not_exists {
    create_machine_aliases
    local alias_file="$HOME/.bash_aliases_machine.sh"
    local alias_name="$1"
    local alias_command="$2"

    # Check if the alias already exists in the file
    if ! grep -q "alias $alias_name=" "$alias_file"; then
        echo "alias $alias_name='$alias_command'" >> "$alias_file"
   fi
}

function create_machine_configs {
    local alias_file="$HOME/.bash_aliases_machine.sh"

    if [ ! -f "$alias_file" ]; then
        cat << 'EOF' > "$alias_file"
###############################################################################
#
# File to hold bash aliases specific to the machine
#
###############################################################################
EOF
    fi

    local alias_file="$HOME/.bashrc_machine.sh"
    touch "$alias_file"
}

function wsl_install {
    # windows/wsl instance specific aliases
    if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]; then
        add_alias_if_not_exists e "explorer.exe ."
    fi
}

function nixos_install {
    NIX_DIR="$WORKING_DIR/nixos/hosts/"

    if [ "$HOSTNAME" == "nixos" ]; then
        # if brand new machine
        read -p "New hostname: " HOSTNAME
        NIX_DIR+="$HOSTNAME"
        mkdir -p "$NIX_DIR"

        # copy new configs to new dir
        sudo mv /etc/nixos/configuration.nix "$NIX_DIR"/default.nix
    else
        # if restoring machine
        NIX_DIR+="$HOSTNAME"
        # clear /etc/nixos
        sudo rm /etc/nixos/configuration.nix
    fi

    sudo mv /etc/nixos/hardware-configuration.nix "$NIX_DIR"
    sudo chown -R "$USER":users "$NIX_DIR"

    # link configs
    # TODO: don't think this is actually necessary tbh
    sudo ln -s "$NIX_DIR"/default.nix /etc/nixos/configuration.nix
    sudo ln -s "$NIX_DIR"/hardware-configuration.nix /etc/nixos/

    # rebuild
    if git add nixos/hosts/"$HOSTNAME"; then
        echo -e "\`git add\` failed! This will break NixOS build process.\nMake sure you're in $HOME/.dotfiles"
        exit 1
    fi
    "$WORKING_DIR"/nixos/rebuild.sh --hostname "$HOSTNAME"
}

function full_install {
    # assume this is a brand new machine

    # create folders
    create_dir personal
    create_dir work

    # create file for holding machine specific aliases
    create_machine_configs

    # assume this is a new machine and needs ssh-keys
    print_info "Create new SSH key for PERSONAL github"
    ./ssh-key.sh
    read -p "Upload key to appropriate site, then press enter" _

    # index if it doesn't exist
    if [ ! -d "$HOME/personal/idx" ]; then
        if git clone git@github.com:cartwatson/idx "$HOME/personal/idx"; then
            print_success "Cloned index"
        else
            print_error "Couldn't clone index over ssh"
        fi
    fi

    symlink_config
    dotfiles_repo_https_to_ssh

    if [ ! -f ~/.hushlogin ]; then touch ~/.hushlogin; fi

    if command -v helix &> /dev/null; then
        reinstall_helix_config
    fi

    wsl_install

    if [ -d /etc/nixos ]; then
        nixos_install
    fi
}

function reinstall {
    symlink_config

    # never hurts to redo these parts
    reinstall_helix_config
}

function remote_machine_install {
    if [ ! -f ~/.hushlogin ]; then touch ~/.hushlogin; fi

    # install bashrc bash_aliases etc
    create_machine_configs
    symlink_config

    # install helix config if found
    reinstall_helix_config

    if [ ! -d ~/.ssh ]; then
        mkdir ~/.ssh;
    fi
}

function welcome_menu {
    echo "
 _       __________   __________  __  _________
| |     / / ____/ /  / ____/ __ \/  |/  / ____/
| | /| / / __/ / /  / /   / / / / /|_/ / __/
| |/ |/ / /___/ /__/ /___/ /_/ / /  / / /___
|__/|__/_____/_____\____/\____/_/  /_/_____/
   _________    ____ ________________
  / ____/   |  / __ /_  __/ ____/ __ \\
 / /   / /| | / /_/ // / / __/ / /_/ /
/ /___/ ___ |/ _, _// / / /___/ _, _/
\____/_/  |_/_/ |_|/_/ /_____/_/ |_|
    "

    echo
    echo "Select an option:"
    echo "    1) Full install"
    echo "    2) Reinstall"
    echo "    3) Remote Machine Install"
    echo "    4) Helix config"
    echo "    5) Generate new SSH key"
    echo "    6) NixOS Install"
    echo "    q) Exit script"
    echo
    read -p "Make your selection [1-6]: " choice

    case $choice in
        1) full_install ;;
        2) reinstall ;;
        3) remote_machine_install ;;
        4) reinstall_helix_config ;;
        5) ./ssh-key.sh ;;
        6) nixos_install ;;
        *) echo "Exiting script"; exit 0 ;;
    esac
}

welcome_menu

if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
