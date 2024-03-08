#!/usr/bin/env bash
# Author: github.com/cartwatson
# Desc: Init new systems with config files

function ask() {
    read -p "$1 (Y/n): " resp
    [ -z "$resp" ] || [ "$resp" = "y" ] || [ "$resp" = "Y" ]
}

function backup()     { if [   -f ~/."$1" ]; then mv ~/."$1" ~/."$1".old; fi }
function create_dir() { if [ ! -d ~/"$1"  ]; then mkdir -p ~/"$1";        fi }

# create folders
create_dir personal
create_dir work
echo "Created ~/personal and ~/work directories..."

# ssh-keygen
if ask "Generate new ssh-key?"; then source ./ssh-key.sh; fi

if ask "Convert from https to ssh for this repo?"; then
    git remote set-url origin git@github.com:cartwatson/.dotfiles.git
fi

if ask "Clone The Index to ~/personal?"; then
    git clone git@github.com:cartwatson/index ~/personal/index
fi

if [ ! -f ~/.hushlogin ]; then touch ~/.hushlogin; fi

# create backups
if ask "Create backups and link .bashrc, .bash_aliases, .vimrc, tmux.conf, and .gitconfig?"; then
    backup bashrc
    backup bash_aliases
    backup vimrc
    backup gitconfig
    backup tmux.conf
    echo -e "Created backups"
    
    # create symlinks for files
    echo "Creating symlinks for bashrc, aliases, vimconfig, and gitconfig..."
    ln -s ~/.dotfiles/bashrc.sh          ~/.bashrc
    ln -s ~/.dotfiles/aliases.sh         ~/.bash_aliases
    ln -s ~/.dotfiles/vimrc.vim          ~/.vimrc
    ln -s ~/.dotfiles/gitconfig-personal ~/.gitconfig
    ln -s ~/.dotfiles/tmux.conf          ~/.tmux.conf
    # don't create symlink here so this file can be edited
    ln    ~/.dotfiles/gitconfig-personal ~/work/.gitconfig
fi

if ask "Will you be using helix?"; then
    create_dir .config/helix
    ln -s ~/.dotfiles/helix-config.toml ~/.config/helix/config.toml
fi

if ask "Install vim plugins?"; then
    create_dir .vim/colors
    # clone down the repos for plugins
    curl "https://raw.githubusercontent.com/aditya-azad/candle-grey/master/colors/candle-grey.vim" > ~/.vim/colors/candle-grey.vim
    git clone https://github.com/tomasiser/vim-code-dark.git  ~/.vim/pack/cwatson/start/vim-code-dark
    git clone https://github.com/morhetz/gruvbox.git          ~/.vim/pack/cwatson/start/gruvbox
    git clone https://github.com/preservim/nerdtree.git       ~/.vim/pack/cwatson/start/nerdtree
    git clone https://github.com/airblade/vim-gitgutter.git   ~/.vim/pack/cwatson/start/vim-gitgutter

    # install helptags
    vim -u NONE -c "helptags ALL" -c q
fi

# dynamically create machine specific aliases
if ask "Create machine aliases file?"; then
    backup bash_machine_aliases.sh
    cp ./machine_aliases.sh ~/.bash_machine_aliases.sh

    code_extensions=( 
                    "ritwickdey.liveserver"        # live server
                    "yzhang.markdown-all-in-one"   # markdown all in one
                    "pkief.material-icon-theme"    # material icon theme
                    )

    # windows/wsl instance specific aliases
    if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]; then
        echo "installing WSL specific files and aliases..."

        echo 'alias e="explorer.exe ." # open windows explorer in current directory' >> ~/.bash_machine_aliases.sh
        code_extensions+=("ms-vscode-remote.remote-wsl");  # wsl extension

        echo -e "WSL files and aliases created\n"
    fi

    if ask "Are you using vscode/vscodium?"; then
        VSCODE="code"
        if ask "Are you using vscodium?"; then VSCODE="codium"; fi

        # now loop through the above array
        for extension in "${code_extensions[@]}"
        do
            $VSCODE --install-extension $extension
        done

        # create alias
        echo -e "alias c=\"""$VSCODE"" .\" # open vscode/vscodium in current directory" >> ~/.bash_machine_aliases.sh
    fi
fi

echo -e "\nInstall Complete!"

# finalize
if [ -f ~/.bashrc ]; then source ~/.bashrc; fi

