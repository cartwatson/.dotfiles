#!/usr/bin/env bash
# Author: github.com/cartwatson
# Desc: Init new systems with config files

function ask() {
    read -p "$1 (Y/n): " resp
    [ -z "$resp" ] || [ "$resp" = "y" ] || [ "$resp" = "Y" ] 
}

# create folders
echo "Attempting to create ~/personal and ~/work directories..."
if [ ! -d ~/personal ]; then mkdir ~/personal; fi
if [ ! -d ~/work     ]; then mkdir ~/work    ; fi

if ask "Would you like to clone The Index to ~/personal?"; then
    git clone git@github.com:cartwatson/index ~/personal/index
fi

# hush login
if ask "Would you like to hush login messages?"; then touch ~/.hushlogin; fi

# create backups
if ask "Would you like to create backups and link .bashrc, .bash_aliases, .vimrc, and .gitconfig?"; then
    echo "Creating backups of .bashrc, bash_aliases, .vimrc, and .giconfig ..."
    if [ -f ~/.bashrc       ]; then mv ~/.bashrc       ~/.bashrc.old      ; fi
    if [ -f ~/.bash_aliases ]; then mv ~/.bash_aliases ~/.bash_aliases.old; fi
    if [ -f ~/.vimrc        ]; then mv ~/.vimrc        ~/.vimrc.old       ; fi
    if [ -f ~/.gitconfig    ]; then mv ~/.gitconfig    ~/.gitconfig.old   ; fi

    # create symlinks for files
    echo "Creating symlinks for bashrc, aliases, vimconfig, and gitconfig..."
    ln -s ~/.dotfiles/bashrc.sh          ~/.bashrc
    ln -s ~/.dotfiles/aliases.sh         ~/.bash_aliases
    ln -s ~/.dotfiles/vimrc.vim          ~/.vimrc
    ln -s ~/.dotfiles/gitconfig-personal ~/.gitconfig
    # don't create symlink here so this file can be edited
    ln    ~/.dotfiles/gitconfig-personal ~/work/.gitconfig
fi

if ask "Will you be using helix?"; then
    if [ ! -d ~/.config/helix ]; then mkdir -p ~/.config/helix; fi
    ln -s ~/.dotfiles/helix-config.toml ~/.config/helix/config.toml
fi

if ask "Would you like to install vim plugins?"; then
    if [ ! -d ~/.vim ] || [ ! -d ~/.vim/colors ]; then mkdir -p ~/.vim/colors; fi
    # clone down the repos for plugins
    # curl "https://raw.githubusercontent.com/vim/vim/master/runtime/colors/slate.vim" > ~/.vim/colors/slate-truecolor.vim
    curl "https://raw.githubusercontent.com/aditya-azad/candle-grey/master/colors/candle-grey.vim" > ~/.vim/colors/candle-grey.vim
    git clone https://github.com/morhetz/gruvbox.git        ~/.vim/pack/cwatson/start/gruvbox
    git clone https://github.com/preservim/nerdtree.git     ~/.vim/pack/cwatson/start/nerdtree
    git clone https://github.com/airblade/vim-gitgutter.git ~/.vim/pack/cwatson/start/vim-gitgutter

    # install helptags
    vim -u NONE -c "helptags ALL" -c q
fi

# dynamically create machine specific aliases
if [ -f ~/.bash_machine_aliases.sh ]; then cp ~/.bash_machine_aliases.sh ~/.bash_machine_aliases.sh.old; fi
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

# arch install
if [ -f "/etc/arch-release" ]; then
    echo "installing arch specific files..."
    ln -s ~/.dotfiles/arch/.Xdefaults ~/.Xdefaults
    echo -e "arch files installed\n"
fi

if ask "Are you using a window manager?"; then
    # provide user with a selection of window managers 
    options=("i3" "Awesome" "Sike, I'm not using a window manager")
    select opt in "${options[@]}"
    do
        case $opt in
            "i3")
                if [ ! -d ~/.config/i3 ]; then 
                    mkdir -p ~/.config/i3; 
                else
                    mv ~/.config/i3/config ~/.config/i3/config.old
                fi
                ln -s ~/.dotfiles/windowManagers/i3/config ~/.config/i3/config

                # configure status bar
                if [ ! -d ~/.config/i3status ]; then
                    mkdir -p ~/.config/i3status;
                else
                    mv ~/.config/i3status/config ~/.config/i3status/config.old
                fi
                ln -s ~/.dotfiles/windowManagers/i3status/config ~/.config/i3status/config
                break
                ;;
            "Awesome")
                echo "Haven't used awesome yet so nothing to do here"
                break
                ;;
            "Sike, I'm not using a window manager")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done

    # polybar config
    if ask "Are you using polybar? "; then
        cp ~/.config/polybar/config.ini ~/.config/polybar/config.ini.old
        ln -s ~/.dotfiles/windowManagers/misc/polybar/config.ini ~/.config/polybar/config.ini
    fi
fi

echo -e "\nInstall Complete!"

# finalize
source ~/.bashrc

