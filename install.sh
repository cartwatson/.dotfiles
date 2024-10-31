#!/usr/bin/env bash
# Author: github.com/cartwatson
# Desc: Init new systems with config files

# Define ANSI escape codes
red_bg="\033[41m"     # Red background
blue_bg="\033[44m"    # Blue background
green_bg="\033[42m"   # Green background
reset="\033[0m"       # Reset formatting

# fun functions for creating distinct visuals
print_error() { echo -e "${red_bg}ERROR: $1${reset}"; }
print_pending() { echo -e "${blue_bg}Pending: $1${reset}"; }
print_success() { echo -e "${green_bg}Completed: $1${reset}"; }
print_info() { echo -e "${blue_bg}Info: $1${reset}"; }

function backup() {
    if [ -f ~/."$1" ]; then
        mv ~/."$1" ~/."$1".old;
    fi
}

function create_dir() {
    if [ ! -d ~/"$1" ]; then
        print_pending "Creating $1..."
        mkdir -p ~/"$1";
        if [ $? -eq 0 ]; then
            print_success "Created $1"
        else
            print_error "Creating $1"
        fi
    fi
}

# installation functions
function symlink_config {
    # create backups
    # TODO: if "these aren't symlinks" then backup
    if [ ! -z "$1" ]; then
        print_pending "Creating bashrc and gitconfig backups..."
        backup bashrc
        backup gitconfig
        print_success "Created backups"
    fi
    
    # create symlinks for files
    print_pending "Creating symlinks for bashrc, aliases, vimconfig, gitconfig, and tmuxconfig..."
    ln -s ~/.dotfiles/bashrc.sh          ~/.bashrc
    ln -s ~/.dotfiles/aliases.sh         ~/.bash_aliases
    ln -s ~/.dotfiles/vimrc.vim          ~/.vimrc
    ln -s ~/.dotfiles/gitconfig-personal ~/.gitconfig
    ln -s ~/.dotfiles/tmux/tmux.conf     ~/.tmux.conf

    if [ ! -f ~/work/.gitconfig ]; then
        # don't create symlink here so this file can be edited
        ln ~/.dotfiles/gitconfig-personal ~/work/.gitconfig
    fi

    print_success "Created symlinks!"
}

function dotfiles_repo_https_to_ssh {
    # convert this repo to ssh if https
    if git remote get-url origin | grep -qc https; then
        print_pending "Converting from https to ssh..."
        git remote set-url origin git@github.com:cartwatson/.dotfiles.git
        if [ $? -eq 0 ]; then
            print_success "Converted \`~/.dotfiles\` from https to ssh"
        else
            print_error "Converting \`~/.dotfiles\` from https to ssh"
        fi
    fi
}

function reinstall_helix_config {
    print_pending "Installing helix config..."
    create_dir .config/helix/themes

    # symlink definition
    # source
    # target
    helix_symlinks=(
        ~/.dotfiles/helix/config.toml
        ~/.config/helix/config.toml

        ~/.dotfiles/helix/langauges.toml
        ~/.config/helix/langauges.toml

        ~/.dotfiles/helix/gruvbox_custom.toml
        ~/.config/helix/themes/gruvbox_custom.toml

        ~/.dotfiles/helix/ignore
        ~/.config/helix/ignore
    )

    # Loop through the array elements
    failed=0
    for ((i = 0; i < ${#helix_symlinks[@]}; i += 2)); do
        source=${helix_symlinks[i]}
        target=${helix_symlinks[i+1]}
        # ln -sf $source $target > /dev/null 2>&1 || ((failed++))
        ln -sf $source $target || ((failed++))
    done

    if [ "$failed" -eq 0 ]; then
        print_success "Installed helix config"
    else
        print_error "Failed to link $failed aspects of helix config"
    fi
}

function add_alias_if_not_exists {
    local alias_file="$HOME/.bash_machine_aliases.sh"
    local alias_name="$1"
    local alias_command="$2"

    # Check if the alias already exists in the file
    if ! grep -q "alias $alias_name=" "$alias_file"; then
        echo "alias $alias_name='$alias_command'" >> "$alias_file"
   fi
}


function create_machine_aliases {
    local alias_file="$HOME/.bash_machine_aliases.sh"

    if [ ! -f "$alias_file" ]; then
        cat << 'EOF' > "$alias_file"
###############################################################################
#
# File to hold bash aliases specific to the machine
#
###############################################################################
EOF

    fi
}

function install_vscode_extensions {
    if command -v code &> /dev/null || command -v codium &> /dev/null; then
        VSCODE="code"
        if command -v codium &> /dev/null; then VSCODE="codium"; fi

        # vscode extensions
        code_extensions=( 
                        "ritwickdey.liveserver"        # live server
                        "yzhang.markdown-all-in-one"   # markdown all in one
                        "pkief.material-icon-theme"    # material icon theme
                        "jdinhlife.gruvbox"            # gruvbox theme duh
                        )

        if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]; then
            code_extensions+=("ms-vscode-remote.remote-wsl");  # wsl extension
        fi

        # install vscode extensions
        for extension in "${code_extensions[@]}"; do
            $VSCODE --force --install-extension $extension
        done

        add_alias_if_not_exists "c" "$VSCODE ."
    fi
}

function wsl_install {
    # windows/wsl instance specific aliases
    if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]; then
        add_alias_if_not_exists e "explorer.exe ."
    fi
}

function nixos_install {
    # link config
    ln -s ~/.dotfiles/nixos/configuration.nix /etc/nixos
}

function full_install {
    # assume this is a brand new machine

    # create folders
    create_dir personal
    create_dir work

    # create file for holding machine specific aliases
    create_machine_aliases

    # assume this is a new machine and needs ssh-keys
    print_info Create new SSH key for personal github
    source ./ssh-key.sh
    read -p "Upload key to appropriate site, then press enter" _

    # index if it doesn't exist
    if [ ! -d ~/personal/index ]; then
        git clone git@github.com:cartwatson/index ~/personal/index
        if [ $? -eq 0 ]; then
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

    install_vscode_extensions

    wsl_install

    if [ -d /etc/nixos ]; then
        nixos_install
    fi
}

function reinstall {
    # don't overwrite `.old` files (provide 1 argument)
    symlink_config dontbackup

    # never hurts to redo this part
    reinstall_helix_config
}

function remote_machine_install {
    if [ ! -f ~/.hushlogin ]; then touch ~/.hushlogin; fi

    # install bashrc bash_aliases etc
    create_machine_aliases
    symlink_config

    # install helix config if found
    reinstall_helix_config

    if [ ! -d ~/.ssh ]; then
        mkdir ~/.ssh;
    fi
}

function welcome_menu {
    # \\ is required at end of second line because it will escape the newline otherwise
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

    # actually start menu
    echo
    echo "Select an option:"
    echo "    1) Full install"
    echo "    2) Reinstall"
    echo "    3) Remote Machine Install"
    echo "    4) Helix config"
    echo "    5) VSCod(e/ium) extensions"
    echo "    6) Generate new SSH key"
    echo "Enter) Full install"
    echo
    local choice
    read -p "Make your selection [1-5]: " choice

    case $choice in
        1) full_install ;;
        2) reinstall ;;
        3) remote_machine_install ;;
        4) reinstall_helix_config ;;
        5) install_vscode_extensions ;;
        6) source ./ssh-key.sh ;;
        *|"") echo "Invalid option. Defaulting to full install." ;;
    esac
}

welcome_menu

if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
