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

function ask() {
    read -p "$1 (Y/n): " resp
    [ -z "$resp" ] || [ "$resp" = "y" ] || [ "$resp" = "Y" ]
}

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

echo -e "Init system configuration\n"

# create folders
create_dir personal
create_dir work

################################################################################
# Manaul Section
################################################################################

# ssh-keygen
if ask "Generate new ssh-key?"; then source ./ssh-key.sh; fi

# only ask to clone index if it doesn't exist
if [ ! -d ~/personal/index ]; then
    if ask "Clone The Index to ~/personal?"; then
        git clone git@github.com:cartwatson/index ~/personal/index
        if [ $? -eq 0 ]; then
            print_success "Cloned index"
        else
            print_error "Couldn't clone index over ssh"
        fi
    fi
fi

# create backups
if ask "Create backups and link .bashrc, .bash_aliases, .vimrc, tmux.conf, and .gitconfig?"; then
    backup bashrc
    backup bash_aliases
    backup vimrc
    backup gitconfig
    backup tmux.conf
    print_success "Created backups"
    
    # create symlinks for files
    print_pending "Creating symlinks for bashrc, aliases, vimconfig, and gitconfig..."
    ln -s ~/.dotfiles/bashrc.sh          ~/.bashrc
    ln -s ~/.dotfiles/aliases.sh         ~/.bash_aliases
    ln -s ~/.dotfiles/vimrc.vim          ~/.vimrc
    ln -s ~/.dotfiles/gitconfig-personal ~/.gitconfig
    ln -s ~/.dotfiles/tmux.conf          ~/.tmux.conf
    # don't create symlink here so this file can be edited
    ln    ~/.dotfiles/gitconfig-personal ~/work/.gitconfig

    # TODO: no measurement of success yet
fi

################################################################################
# Auto/Semi-Auto Section
################################################################################

# convert this repo to ssh if https
if git remote get-url origin | grep -qc https; then
    print_pending "Converting from https to ssh..."
    git remote set-url origin git@github.com:cartwatson/.dotfiles.git
    # TODO: actually test ability to connect here
    if [ $? -eq 0 ]; then
        print_success "Converted \`~/.dotfiles\` from https to ssh"
    else
        print_error "Converting \`~/.dotfiles\` from https to ssh"
    fi
fi

if [ ! -f ~/.hushlogin ]; then touch ~/.hushlogin; fi

if command -v helix &> /dev/null || ask "Install helix config?"; then
    print_pending "Installing helix config..."
    create_dir .config/helix/themes

    # symlink definition
    # source
    # target
    helix_config=(
        ~/.dotfiles/helix/config.toml
        ~/.config/helix/config.toml

        ~/.dotfiles/helix/langauges.toml
        ~/.config/helix/langauges.toml

        ~/.dotfiles/helix/gruvbox_custom.toml
        ~/.config/helix/themes/gruvbox_custom.toml
    )

    # Loop through the array elements
    failed=0
    for ((i = 0; i < ${#helix_config[@]}; i += 2)); do
        source=${helix_config[i]}
        target=${helix_config[i+1]}
        # ln -sf $source $target > /dev/null 2>&1 || ((failed++))
        ln -sf $source $target || ((failed++))
    done

    if [ "$failed" -eq 0 ]; then
        print_success "Installed helix config"
    else
        print_error "Failed to link $failed aspects of helix config"
    fi
fi

# Keep vim vanilla
# if command -v vim &> /dev/null || ask "Install vim plugins?"; then
#     echo -e "Installing vim plugins & colorschemes"
#     create_dir .vim/colors
#     # clone down the repos for plugins
#     # TODO: if exists, git pull; else clone
#     curl "https://raw.githubusercontent.com/aditya-azad/candle-grey/master/colors/candle-grey.vim" > ~/.vim/colors/candle-grey.vim
#     git clone https://github.com/tomasiser/vim-code-dark.git  ~/.vim/pack/cwatson/start/vim-code-dark
#     git clone https://github.com/morhetz/gruvbox.git          ~/.vim/pack/cwatson/start/gruvbox
#     git clone https://github.com/preservim/nerdtree.git       ~/.vim/pack/cwatson/start/nerdtree
#     git clone https://github.com/airblade/vim-gitgutter.git   ~/.vim/pack/cwatson/start/vim-gitgutter

#     # install helptags
#     vim -u NONE -c "helptags ALL" -c q
# fi

# dynamically create machine specific aliases
if [ ! -f ~/.bash_machine_aliases.sh ] || ask "Create machine aliases file?"; then
    cp ./machine_aliases.sh ~/.bash_machine_aliases.sh

    code_extensions=( 
                    "ritwickdey.liveserver"        # live server
                    "yzhang.markdown-all-in-one"   # markdown all in one
                    "pkief.material-icon-theme"    # material icon theme
                    "jdinhlife.gruvbox"            # gruvbox theme duh
                    )

    # windows/wsl instance specific aliases
    if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]; then
        print_pending "Installing WSL specific files and aliases..."

        code_extensions+=("ms-vscode-remote.remote-wsl");  # wsl extension
        echo 'alias e="explorer.exe ." # open windows explorer in current directory' >> ~/.bash_machine_aliases.sh

        if [ $? -eq 0 ]; then
            print_success "WSL files and aliases created"
        else
            print_error "Couldn't create WSL aliases"
        fi
    fi

    # TODO: move this section out of here
    if command -v code &> /dev/null || command -v codium &> /dev/null || ask "Are you using vscode/vscodium?"; then
        VSCODE="code"
        if command -v codium &> /dev/null; then VSCODE="codium"; fi

        # now loop through the above array
        for extension in "${code_extensions[@]}"; do
            $VSCODE --force --install-extension $extension
        done

        # create alias
        echo -e "alias c=\"""$VSCODE"" .\" # open vscode/vscodium in current directory" >> ~/.bash_machine_aliases.sh
    fi
fi

echo
print_success "Machine Initialization!\n"

# finalize
if [ -f ~/.bashrc ]; then source ~/.bashrc; fi

