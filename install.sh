###############################################################################
#
# Init new systems with config files
#
###############################################################################

# function to ask user y/n questions
# credit to bartekspitza on github
function ask() {
    read -p "$1 (Y/n): " resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
    fi

    [ "$response_lc" = "y" ]
}

# create folders
echo "Creating ~/personal and ~/work directories..."
if [ ! -d ~/personal ]; then mkdir ~/personal; fi
if [ ! -d ~/work     ]; then mkdir ~/work    ; fi

if ask "Would you like to clone The Index to ~/personal?"; then
    git clone git@github.com:cartwatson/index ~/personal/index
    # git clone https://github.com/cartwatson/index ~/personal/index
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
    ln -s ~/.dotfiles/vim/vimrc.vim      ~/.vimrc
    ln -s ~/.dotfiles/gitconfig-personal ~/.gitconfig
    # don't create symlink here so this file can be edited
    ln    ~/.dotfiles/gitconfig-personal ~/work/.gitconfig
fi

if ask "Would you like to install custom colorschemes for vim?"; then
    if [ ! -d ~/.vim ]; then mkdir ~/.vim; fi
    ln -s ~/.dotfiles/vim/colors ~/.vim/
fi

if ask "Would you like to install vim-airline?"; then
    if [ ! -d ~/.vim ]; then mkdir ~/.vim; fi
    # clone down the repos for airline + themes
    git clone https://github.com/vim-airline/vim-airline ~/.vim/pack/dist/start/vim-airline
    git clone https://github.com/vim-airline/vim-airline-themes ~/.vim/pack/dist/start/vim-airline-themes

    # this command needs to run in vimscript to generate docs
    # TODO: add this to vimrc
    echo -e "run :helptags ~/.vim/pack/dist/start/vim-airline/doc\n"
fi

# dynamically create machine specific aliases
if ask "Create ~/.bash_machine_aliases.sh?"; then
    cp ./machine_aliases.sh ~/.bash_machine_aliases.sh

    if ask "Are you using vscode/vscodium?"; then
        declare -a code_extensions=(
                                    "ms-vscode-remote.remote-wsl"  # wsl extension
                                    "ritwickdey.liveserver"        # live server
                                    "yzhang.markdown-all-in-one"   # markdown all in one
                                    "pkief.material-icon-theme"    # material icon theme
                                    "swyphcosmo.spellchecker"      # spell checker
                                    )

        VSCODE="code"
        if ask "Are you using vscodium?"; then
            VSCODE="codium"
        fi

        ## now loop through the above array
        for extension in "${code_extensions[@]}"
        do
            if ask "Would you like to install $extension?"; then
                $VSCODE --install-extension $extension
            fi
        done

        echo -e 'alias c="$VSCODE ." # open vscode/vscodium in current directory' >> ~/.bash_machine_aliases.sh
    fi

    # windows/wsl instance specific aliases
    if ask "Is this a wsl instance?"; then
        echo 'alias e="explorer.exe ." # open windows explorer in current directory' >> ~/.bash_machine_aliases.sh
    fi

    # arch install
    if ask "Is this an arch machine? (set terminal theme to dark) "; then
    	ln -s ~/.dotfiles/arch/.Xdefaults ~/.Xdefaults
    fi

    if ask "Are you using a window manager? "; then
        # provide user with a selection of window managers 
        options=("i3" "Awesome" "Sike, I'm not using a window manager")
        select opt in "${options[@]}"
        do
            case $opt in
                "i3")
		            cp ~/.config/i3/config ~/.config/i3/config.old
                    ln -s ~/.dotfiles/windowManagers/i3/config ~/.config/i3/config
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
fi

echo -e "\nInstall Complete!"

# finalize
source ~/.bashrc

